class UserRoutes < EhrApiBase

  post '/authorize' do
    user = User.authenticate(params[:identifier], params[:password]) || forbidden!
    token = Token.find_or_create(user.id)

    json user: user.present(params).merge({
      token: token.value
    })
  end

  namespace('/users') do
    before { authenticate! }

    get do
      json paginated(:users, current_user.users_dataset)
    end

    post do
      create! User, user_attributes
    end

    get '/:id' do
      user = User[params[:id].to_i] || not_found!
      json user.present(params)
    end

    put '/:id' do
      user = User[params[:id].to_i] || not_found!
      verify_current_user_or_staff!(user)

      tags = user_attributes.delete('tags') || []
      DB.transaction do
        # validate current tags
        user.tags.each do |tag|
          unless tags.include? tag.name
            user.remove_tag tag
          end
        end

        # Add new tags
        tags.each do |tag|
          _tag = Tag.find_or_create(tag)
          user.add_tag _tag unless user.tags.include?(_tag)
        end

        update! user, user_attributes, User
      end
    end
  end

  def user_attributes
    attrs = params[:user] || bad_request!
    whitelist!(attrs, :first_name, :last_name, :role, :advocate_id, :birthdate, :gender,
               :sexual_orientation, :phone, :email, :username, :hive_postiive, :language,
               :race, :mailing_address, :home_address, :tags)

    rename_nested_attributes!('mailing_address', attrs, User, params[:id],
                              :street, :street_2, :city, :state, :zipcode)
    rename_nested_attributes!('home_address', attrs, User, params[:id],
                              :street, :street_2, :city, :state, :zipcode)
    attrs
  end
end

