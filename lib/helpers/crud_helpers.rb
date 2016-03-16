module CRUDHelpers
  def create!(klass, attributes)
    klass.whitelist! attributes

    object = klass.new attributes

    unprocessable_entity!(object.errors) unless object.save

    response.status = 201
    klass[object.id].present
  end

  def update!(object, attributes, klass = nil)
    object.set attributes

    unprocessable_entity!(object.errors) unless object.save

    response.status = 200

    # reload the updated object before returning it.
    # We need to use this way instead of object.reload,
    # because in STI when the kind attribute is changed,
    # object.reload will throw an error.
    object = klass.fetch(object.id) if klass

    object.present
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

  def rename_nested_attributes!(key_name, attrs, parent_class, parent_id, *fields)
    if attrs.key? key_name
      if parent = parent_class[parent_id]
        existing_obj = parent.send(key_name)
      end

      # delete existing content if nil is sent
      if attrs[key_name].nil?
        if existing_obj
          attrs["#{key_name}_attributes".to_sym] = { id: existing_obj.id, _delete: true }
        end
        attrs.delete key_name
      else
        whitelisted_attrs = whitelist! attrs.delete(key_name), *fields
        whitelisted_attrs[:id] = existing_obj.id if existing_obj
        attrs["#{key_name}_attributes".to_sym] = whitelisted_attrs
      end
    end
  end
end
