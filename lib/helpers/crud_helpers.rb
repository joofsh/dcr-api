module CRUDHelpers
  def create!(klass, attributes)
    klass.whitelist! attributes

    object = klass.new attributes

    unprocessable_entity!(object.errors) unless object.save

    response.status = 201
    json klass[object.id].present
  end

  def update!(object, attributes, klass)
    object.set attributes

    unprocessable_entity!(object.errors) unless object.save

    response.status = 200

    # reload the updated object before returning it.
    # We need to use this way instead of object.reload,
    # because in STI when the kind attribute is changed,
    # object.reload will throw an error.
    object = klass.fetch(object.id) if klass

    json object.present
  end

  def whitelist!(attrs, *fields)
    attrs.keep_if { |k, _v| fields.include?(k.to_sym) }
  end

  def paginated(name, dataset, length = 10)
    length = params[:length] || length
    start = params[:start] || 0

    dataset = dataset.limit(length, start)
    total = dataset.count

    records = dataset.all

    {
      name => records.map { |r| r.present(params) },
      count: total,
      length: length.to_i,
      start: start.to_i,
    }
  end
end
