class TagRoutes < EhrApiBase
  route do |r|
    authenticate!

    r.get do
      paginated(:tags, Tag.dataset)
    end
  end
end
