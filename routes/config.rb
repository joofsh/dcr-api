class ConfigRoutes < EhrApiBase
  route do |r|
    r.get 'healthcheck' do
      {
        users: User.count,
        resources: Resource.count,
        tokens: Token.count
      }
    end
  end
end
