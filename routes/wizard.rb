class WizardRoutes < EhrApiBase
  route do |r|
    authenticate!

    r.on ':user_id' do |user_id|
      user = User[user_id] || not_found!

      if current_user.guest?
        user == current_user || forbidden!
      elsif current_user.staff?
        current_user.clients.include?(user) || forbidden!
      end

      r.get 'current_question' do
        { question: Question.current_for_user(user).present }
      end

      r.get 'resources' do
        {
          user: user.present(params),
          resources: user.resource_map.reduce({}) do |hash, (tag, resources)|
            hash[tag] = resources.map { |r| r.present(params) }
            hash
          end
        }
      end

      r.put 'responses' do

        choice = Choice[params[:choice_id]] || not_found!

        response = Response.create_or_update(user.id, choice.question_id, choice.id)

        choice.tags.each do |tag|
          user.add_tag(tag) unless user.tags.include? tag
        end

        {
          next_question: choice.next_question && choice.next_question.present,
          response: response.present
        }
      end
    end
  end
end
