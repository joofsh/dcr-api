class ConfigRoutes < EhrApiBase
  get '/healthcheck' do
    json(users: User.count,
         resources: Resource.count,
         tokens: Token.count)
  end
end
