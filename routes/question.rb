class QuestionRoutes < EhrApiBase
  route do |r|
    r.on ':id' do |question_id|
      params[:question_id] = question_id
      question = Question[question_id] || not_found!

      r.get do
        question.present(params)
      end

      r.put do
        verify_staff!
        update! question, question_attributes
      end

      r.delete do
        verify_staff!

        destroy! Question, question.id
      end
    end

    r.get do
      paginated(:questions, Question.dataset.ordered)
    end

    r.post do
      verify_staff!
      create! Question, question_attributes
    end

  end

  def question_attributes
    attrs = params[:question] || bad_request!
    whitelist!(attrs, :order, :stem, :choices)

    rename_nested_attributes!('choices', attrs, Question, params[:question_id],
                              :id, :stem, :question_id, :next_question_id, :tag_pks)

    attrs
  end
end
