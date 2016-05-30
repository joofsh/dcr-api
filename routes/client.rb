class ClientRoutes < EhrApiBase
  route do |r|
    authenticate!

    r.on ':id' do |client_id|
      client = Client[client_id] || not_found!

      r.get 'questions' do

        {
          client: client.present(params),
          questions: client.questions_dataset.map { |q| q.present(params) }
        }
      end

      r.get 'resources' do
        verify_current_user_or_staff!(client)

        {
          client: client.present(params),
          resources: client.resources.first(5).map{ |r| r.present(params) }
        }
      end

      r.put 'responses' do
        verify_current_user_or_staff!(client)

        choice = Choice[params[:choice_id]] || not_found!

        response = Response.create_or_update(client.id, choice.question_id, choice.id)

        choice.tags.each do |tag|
          client.add_tag(tag) unless client.tags.include? tag
        end

        {
          next_question: choice.next_question && choice.next_question.present,
          response: response.present
        }
      end
    end
  end
end
