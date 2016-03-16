class ClientRoutes < EhrApiBase
  route do |r|
    authenticate!

    r.on ':id' do |client_id|
      get 'questions' do
        client = Client[client_id] || not_found!

        {
          client: client.present(params),
          questions: client.questions_dataset.map { |q| q.present(params) }
        }
      end

      r.get 'resources' do
        client = Client[client_id] || not_found!

        {
          client: client.present(params),
          resources: client.resources.first(5).map{ |r| r.present(params) }
        }
      end

      r.put 'responses' do
        client = Client[client_id] || not_found!
        choice = Choice[params[:choice_id]] || not_found!

        response = Response.create_or_update(client.id, choice.question_id, choice.id)

        if choice.tag
          client.add_tag(choice.tag) unless client.tags.include? choice.tag
        end

        {
          next_question: choice.next_question.present,
          response: response.present
        }
      end
    end
  end
end
