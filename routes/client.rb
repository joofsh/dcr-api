class ClientRoutes < EhrApiBase
  namespace('/clients') do
    before { authenticate! }

    put '/:id/responses' do
      client = Client[params[:id].to_i] || not_found!
      choice = Choice[params[:choice_id].to_i] || not_found!

      response = Response.create_or_update(client.id, choice.question_id, choice.id)

      if choice.tag
        client.add_tag(choice.tag) unless client.tags.include? choice.tag
      end

      json(
        next_question: choice.next_question.present,
        response: response.present
      )
    end

    get '/:id/resources' do
      client = Client[params[:id].to_i] || not_found!

      json(
        client: client.present(params),
        resources: client.resources.first(5).map{ |r| r.present(params) }
      )
    end

    get '/:id/questions' do
      client = Client[params[:id].to_i] || not_found!

      json(
        client: client.present(params),
        questions: client.questions_dataset.map { |q| q.present(params) }
      )
    end

  end
end

