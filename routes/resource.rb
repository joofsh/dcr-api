class ResourceRoutes < EhrApiBase
  route do |r|
    r.on ':id' do |resource_id|
      params[:resource_id] = resource_id
      resource = Resource[resource_id] || not_found!

      r.get do
        resource.present(params)
      end

      r.put 'publish' do
        verify_staff!
        resource.publish!
        resource.present
      end

      r.put 'unpublish' do
        verify_staff!
        resource.unpublish!
        resource.present
      end

      r.put do
        verify_staff!

        update! resource, resource_attributes
      end
    end

    r.is do
      r.get do
        resource_dataset = current_staff? ? Resource.dataset : Resource.published
        paginated(:resources, resource_dataset)
      end

      r.post do
        create! Resource, resource_attributes
      end
    end
  end

  def resource_attributes
    @resource_attributes ||= begin
      attrs = params[:resource] || bad_request!
      whitelist!(attrs, :operating_hours, :phone, :title, :url, :image_url,
                :description, :email, :category, :population_served, :note, :languages,
                :address, :tag_pks)

      rename_nested_attributes!('address', attrs, Resource, params[:resource_id],
                                :street, :street_2, :city, :state, :zipcode)

      attrs
    end
  end
end

