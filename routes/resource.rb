class ResourceRoutes < EhrApiBase
  namespace('/resources') do
    before { authenticate! }

    get do
      json paginated(:resources, Resource.dataset)
    end

    post do
      create! Resource, resource_attributes
    end

    get '/:id' do
      resource = Resource[params[:id].to_i] || not_found!
      json resource.present(params)
    end

    put '/:id' do
      verify_staff!
      resource = Resource[params[:id].to_i] || not_found!

      update! resource, resource_attributes
    end
  end

  def resource_attributes
    resource = params[:resource] || bad_request!
    whitelist!(resource, :operating_hours, :phone, :title, :url, :image_url)
  end
end

