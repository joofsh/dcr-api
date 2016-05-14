class QuestionRoutes < EhrApiBase
  route do |r|
    r.on ':id' do |question_id|
      question = Question[question_id] || not_found!

      r.get do
        question.present(params)
      end

      r.put do
        verify_staff!
        update! question, question_attributes
      end
    end

    r.get do
      paginated(:questions, Question.dataset)
    end

    r.post do
      verify_staff!
      create! Question, question_attributes
    end
  end

  def question_attributes
    attrs = params[:question] || bad_request!
    whitelist!(attrs, :stem, :choices)

    rename_nested_attributes!('choices', attrs, Choice, params[:id],
                              :id, :stem, :tag_id, :question_id, :next_question_id, :_delete)
    attrs
  end
end
