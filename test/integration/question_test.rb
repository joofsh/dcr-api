require_relative '../helper'

describe 'Questions' do
  before do
    @advocate = Advocate.spawn!
    @question = Question.spawn!
    Choice.spawn! question_id: @question.id
    2.times do
      q = Question.spawn!
      2.times { Choice.spawn! question_id: q.id }
    end
  end

  describe 'GET /questions' do
    it 'doesnt require auth' do
      get '/questions'
      assert_equal 200, status
    end

    it 'returns paginated questions' do
      get '/questions'

      assert_equal 200, status
      assert body.key? :questions
      assert body.key? :count

      assert_equal 3, body[:count]
      question = body[:questions][0]
      assert question.key? :stem
      assert question.key? :choices
    end

    it 'orders them by created_at' do
      Question.each(&:destroy)
      q1 = Question.spawn!(category: 'Education', order: 1)
      q2 = Question.spawn!(category: 'General', order: 2)
      q3 = Question.spawn!(category: 'Education', order: 2)
      q4 = Question.spawn!(category: 'General', order: 1)

      get '/questions'
      assert_equal 200, status
      question_ids = body[:questions].map { |q| q[:id] }
      assert_equal [q1.id, q2.id, q3.id, q4.id], question_ids
    end
  end

  describe 'GET /questions/:id' do
    it 'doesnt require auth' do
      get "/questions/#{@question.id}"
      assert_equal 200, status
    end

    it 'returns a question' do
      get "/questions/#{@question.id}"

      assert_equal 200, status
      assert_equal @question[:id], body[:id]
    end
  end

  describe 'POST /questions' do
    before do
      @attrs = {
        stem: 'What is your address?',
        category: 'Education'
      }
    end

    it 'requires token' do
      post '/questions'
      assert_equal 403, status
    end

    it 'errors with bad content' do
      post user_url('/questions', @advocate), { question: {} }

      assert_equal 422, status
    end

    it 'creates a new question' do
      post user_url('/questions', @advocate), { question: @attrs }

      assert_equal 201, status
      assert_equal @attrs[:stem], body[:stem]
      assert body.key? :id
    end

    it 'creates choices' do
      choices = [{ stem: 'Yes' }, { stem: 'No' }]
      @attrs.merge!(choices: choices)

      post user_url('/questions', @advocate), { question: @attrs }
      assert_equal 201, status
      assert_equal choices.count, body[:choices].count
      assert_equal choices[0][:stem], body[:choices][0][:stem]
    end

    it 'creates tags within choices' do
      tag_1 = Tag.spawn!
      tag_2 = Tag.spawn!
      choices = [{ stem: 'Yes', tags: [tag_1, tag_2] }, { stem: 'No', tags: [tag_1] }]
      @attrs.merge!(choices: choices)
      post user_url('/questions', @advocate), { question: @attrs }
      assert_equal 201, status
      assert_equal choices.count, body[:choices].count
      assert_equal choices[0][:stem], body[:choices][0][:stem]
    end
  end

  describe 'PUT /questions' do
    before do
      @attrs = {
        stem: 'funky new stem',
        category: 'Education'
      }
    end

    it 'requires token' do
      put "/questions/#{@question.id}"
      assert_equal 403, status
    end

    it 'updates the question' do
      assert_equal 1, @question.choices.count
      put user_url("/questions/#{@question.id}", @advocate), { question: @attrs }

      assert_equal 200, status
      assert_equal @attrs[:stem], body[:stem]
      assert_equal @attrs[:category], body[:category]
      assert_equal 1, @question.reload.choices.count
    end

    it 'updates nested choices' do
      original_choice = @question.choices.first
      @attrs.merge!(
        choices: [
          { id: original_choice.id, stem: 'New choice stem 1' },
          { stem: 'Newly created choice' }
        ]
      )
      assert_equal 1, @question.choices.count

      put user_url("/questions/#{@question.id}", @advocate), { question: @attrs }

      assert_equal 200, status
      assert_equal 2, @question.reload.choices.count
      assert_equal @attrs[:choices][0][:stem], original_choice.reload.stem
      assert_equal @attrs[:choices][1][:stem], body[:choices][1][:stem]
    end

    it 'allows deleting nested choices' do
      original_choice = @question.choices.first
      attrs = { choices: [] }

      assert_equal 1, @question.reload.choices.count

      put user_url("/questions/#{@question.id}", @advocate), { question: attrs }

      assert_equal 200, status
      assert_equal 0, @question.reload.choices.count
    end

    it 'allows adding/removing tags from choices' do
      tag_1, tag_2 = Tag.spawn!, Tag.spawn!
      choice = @question.choices.first
      choice.add_tag tag_1

      attrs = { choices: [{ id: choice.id, tag_pks: [tag_2.id] }] }
      put user_url("/questions/#{@question.id}", @advocate), { question: attrs }

      assert_equal 200, status
      assert_equal tag_2.id, body[:choices][0][:tags][0][:id]
      assert_equal [tag_2], choice.reload.tags
    end
  end
end
