class DemoRoutes < EhrApiBase
  route do |r|
    verify_staff!

    r.get 'wizard/resources' do
      {
        user: (Guest.first || Guest.create).present(params),
        resources: User.master_resource_map.reduce({}) do |hash, (tag, resources)|
          hash[tag] = resources.map { |r| r.present(params) }
          hash
        end
      }
    end

  end
end
