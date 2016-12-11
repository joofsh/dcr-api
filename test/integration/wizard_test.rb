require_relative '../helper'

describe 'Wizard' do
  before do
    @guest = Guest.spawn!
    @questions = 3.times.map { |i| Question.spawn! order: i }
  end

  describe 'GET /wizard/:id/current_question' do
    it 'requires token' do
      get "/wizard/#{@guest.id}/questions"
      assert_equal 403, status
    end

    it 'returns guests current question' do
      get user_url("/wizard/#{@guest.id}/current_question", @guest)

      assert_equal 200, status
      assert body.key? :question
      assert body[:question].key? :id
      assert body[:question].key? :stem
      assert_equal @questions.first.id, body[:question][:id]
    end

    it 'skips questions that have been previously answered' do
      choice = Choice.spawn! question: @questions[0]
      Response.spawn! choice: choice, user: @guest, question: choice.question

      get user_url("/wizard/#{@guest.id}/current_question", @guest)

      assert_equal 200, status
      deny choice.next_question
      assert_equal @questions[1].id, body[:question][:id]
    end

    it 'checks for lasts responses next_question' do
      choice = Choice.spawn! question: @questions[0], next_question: @questions[2]
      Response.spawn! choice: choice, user: @guest, question: choice.question

      get user_url("/wizard/#{@guest.id}/current_question", @guest)

      assert_equal 200, status
      assert_equal @questions[2].id, body[:question][:id]
    end
  end

  describe 'GET /wizard/:id/resources' do
    before do
      @tags = [Tag.spawn!(type: 'Service'), Tag.spawn!(type: 'Service')]
      6.times do |i|
        r = Resource.spawn!
        r.add_tag @tags[i % 2]
      end

      @tags.each do |t|
        @guest.add_tag(t)
      end
    end

    it 'requires token' do
      get "/wizard/#{@guest.id}/resources"
      assert_equal 403, status
    end

    it 'returns guests own personalized resources' do
      get user_url("/wizard/#{@guest.id}/resources", @guest)

      assert_equal 200, status
      assert body.key? :user
      assert body.key? :resources
      assert_equal @guest.id, body[:user][:id]
      assert_equal 2, body[:resources].count
      assert body[:resources].keys.include?(@tags[0].name.to_sym)
      assert body[:resources].keys.include?(@tags[1].name.to_sym)

      first_resource_set = body[:resources][@tags[0].name.to_sym]
      assert_equal 3, first_resource_set.count
      assert first_resource_set.first.key? :title
      assert first_resource_set.first.key? :id

      second_resource_set = body[:resources][@tags[1].name.to_sym]
      assert_equal 3, second_resource_set.count
    end
  end

  describe 'PUT /clients/:id/responses' do
    before do
      @question = Question.spawn!
      @next_question = Question.spawn!
      @choice = Choice.spawn! question: @question, next_question: @next_question
      @attrs = {
        choice_id: @choice.id
      }
    end

    it 'requires token' do
      put "/wizard/#{@guest.id}/responses"
      assert_equal 403, status
    end

    it 'creates new response' do
      assert_equal 0, Response.count
      put user_url("/wizard/#{@guest.id}/responses", @guest), @attrs

      assert_equal 200, status
      assert_equal 1, Response.count
      assert body.key? :next_question
      assert body.key? :response
      assert_equal @guest.id, body[:response][:user_id]
      assert_equal @choice.id, body[:response][:choice_id]
      assert_equal @next_question.id, body[:next_question][:id]
      assert_equal @next_question.stem, body[:next_question][:stem]
    end

    it 'updates an existing response' do
      new_choice = Choice.spawn! question: @question

      # original response choice with new_choice
      response = Response.spawn! choice: new_choice, user: @guest

      assert_equal 1, Response.count
      put user_url("/wizard/#{@guest.id}/responses", @guest), @attrs

      assert_equal 200, status
      assert_equal 1, Response.count
      assert_equal @choice.id, body[:response][:choice_id]
      assert_equal response.id, body[:response][:id]
    end

    it 'adds choice\'s associated tag to the client' do
      tag = Tag.spawn!
      @choice.add_tag tag
      deny @guest.tags.include? tag

      put user_url("/wizard/#{@guest.id}/responses", @guest), @attrs

      assert_equal 200, status
      assert @guest.reload.tags.include? tag
    end
  end
end
