class ResourceRoutes < EhrApiBase
  route do |r|
    r.on ':id' do |resource_id|
      r.get do
        resource = Resource[resource_id] || not_found!
        resource.present(params)
      end

      r.put do
        verify_staff!
        resource = Resource[resource_id] || not_found!

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

    r.is do
      r.get do
        paginated(:resources, Resource.dataset)
      end

      r.post do
        create! Resource, resource_attributes
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

