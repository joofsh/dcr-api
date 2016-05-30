require_relative '../helper'

describe 'Clients' do
  before do
    @client = Client.spawn!
    3.times { Question.spawn! }
  end

  describe 'GET /clients/:id/questions' do
    it 'requires token' do
      get "/clients/#{@client.id}/questions"
      assert_equal 403, status
    end

    it 'returns client questions' do
      get user_url("/clients/#{@client.id}/questions")

      assert_equal 200, status
      assert body.key? :client
      assert body.key? :questions
      assert_equal @client.id, body[:client][:id]
      assert_equal 3, body[:questions].count
      assert body[:questions].first.key? :stem
    end
  end

  describe 'GET /client/:id/resources' do
    before do
      tag = Tag.spawn!
      6.times {
        r = Resource.spawn!
        r.add_tag tag
      }
      @client.add_tag tag
      @advocate = Advocate.spawn!
    end

    it 'requires token' do
      get "/clients/#{@client.id}/resources"
      assert_equal 403, status
    end

    it 'returns client customized resources' do
      get user_url("/clients/#{@client.id}/resources", @advocate)

      assert_equal 200, status
      assert body.key? :client
      assert body.key? :resources
      assert_equal @client.id, body[:client][:id]
      assert_equal 5, body[:resources].count
      assert body[:resources].first.key? :title
      assert body[:resources].first.key? :id
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
      put "/clients/#{@client.id}/responses"
      assert_equal 403, status
    end

    it 'creates new response' do
      assert_equal 0, Response.count
      put user_url("/clients/#{@client.id}/responses"), @attrs

      assert_equal 200, status
      assert_equal 1, Response.count
      assert body.key? :next_question
      assert body.key? :response
      assert_equal @client.id, body[:response][:client_id]
      assert_equal @choice.id, body[:response][:choice_id]
      assert_equal @next_question.id, body[:next_question][:id]
      assert_equal @next_question.stem, body[:next_question][:stem]
    end

    it 'updates an existing response' do
      new_choice = Choice.spawn! question: @question

      # original response choice with new_choice
      response = Response.spawn! choice: new_choice, client: @client

      assert_equal 1, Response.count
      put user_url("/clients/#{@client.id}/responses"), @attrs

      assert_equal 200, status
      assert_equal 1, Response.count
      assert_equal @choice.id, body[:response][:choice_id]
      assert_equal response.id, body[:response][:id]
    end

    it 'adds choice\'s associated tag to the client' do
      tag = Tag.spawn!
      @choice.add_tag tag
      deny @client.tags.include? tag

      put user_url("/clients/#{@client.id}/responses"), @attrs

      assert_equal 200, status
      assert @client.reload.tags.include? tag
    end
  end
end
