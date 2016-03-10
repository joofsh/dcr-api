class ResourceRoutes < EhrApiBase
  namespace('/resources') do
    get do
      json paginated(:resources, Resource.dataset)
    end

    get '/:id' do
      resource = Resource[params[:id].to_i] || not_found!
      json resource.present(params)
    end

    post do
      verify_staff!
      create! Resource, resource_attributes
    end

    put '/:id' do
      verify_staff!
      resource = Resource[params[:id].to_i] || not_found!

      tags = resource_attributes.delete('tags') || []
      DB.transaction do
        # validate current tags
        resource.tags.each do |tag|
          unless tags.include? tag.name
            resource.remove_tag tag
          end
        end

        # Add new tags
        tags.each do |tag|
          _tag = Tag.find_or_create(tag)
          resource.add_tag _tag unless resource.tags.include?(_tag)
        end

        update! resource, resource_attributes
      end
    end
  end

  def resource_attributes
    attrs = params[:resource] || bad_request!
    whitelist!(attrs, :operating_hours, :phone, :title, :url, :image_url, :address, :tags)

    rename_nested_attributes!('address', attrs, Resource, params[:id],
                              :street, :street_2, :city, :state, :zipcode)

    attrs
  end
end

