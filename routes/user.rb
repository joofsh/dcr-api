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

      update! user, user_attributes, User
    end
  end

  def user_attributes
    user = params[:user] || bad_request!
    whitelist!(user, :first_name, :last_name, :role, :advocate_id, :birthdate, :gender,
               :sexual_orientation, :phone, :email, :username, :hive_postiive, :language,
               :race)
  end
end

