module CRUDHelpers
  def create!(klass, attributes)
    klass.whitelist! attributes

    object = klass.new attributes

    unprocessable_entity!(object.errors) unless object.save

    response.status = 201
    json klass[object.id].present
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
