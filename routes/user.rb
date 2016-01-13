class UserRoutes < EhrApiBase

  namespace('/users') do
    #before { authenticate! }

    get do
      json paginated(:users, User)
    end

    post do
      create! User, params[:user]
    end

    get '/:id' do
      user = User[params[:id]] || not_found!
      json user.present(params)
    end

    put '/:id' do
      user = User[params[:id]] || not_found!
      verify_current_user_or_staff!(user)
    end
  end

  post '/users/authorize' do
    user = User.authenticate(params[:identifier], params[:password]) || forbidden!
    token = Token.find_or_create(user.id)

    json user.present(params).merge({
      token: token.value
    })
  end
end

