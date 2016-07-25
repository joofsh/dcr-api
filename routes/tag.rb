class TagRoutes < EhrApiBase
  route do |r|
    verify_staff!

    r.on ':id' do |tag_id|
      params[:tag_id] = tag_id
      tag = Tag[tag_id] || not_found!

      r.get do
        tag.present(params)
      end

      r.put do
        update! tag, tag_attributes
      end

      r.delete do
        destroy! Tag, tag.id
      end
    end

    r.get do
      dataset = Tag.ordered
      dataset = dataset.with_details if params[:details]

      paginated(:tags, dataset)
    end

    r.post do
      create! Tag, tag_attributes
    end
  end

  def tag_attributes
    attrs = params[:tag] || bad_request!
    whitelist!(attrs, :name, :type, :weight)
  end
end
