class TagRoutes < EhrApiBase
  namespace('/tags') do

    get do
      json paginated(:tags, Tag.dataset)
    end

  end
end
