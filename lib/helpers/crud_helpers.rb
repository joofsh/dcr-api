module CRUDHelpers
  def create!(klass, attributes = {})
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
    object = klass[object.id] if klass

    object.present
  end

  def destroy!(klass, id)
    object = klass[id] || not_found!

    unprocessable_entity!('Deletion failed!') unless object.destroy

    no_content!
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

  # TODO: Refactor this code. Maybe extract out to separate, smaller methods?
  def rename_nested_attributes!(key_name, attrs, parent_class, parent_id, *fields)
    if attrs.key? key_name
      if parent = parent_class[parent_id]
        existing = parent.send(key_name) # single object or array of objects
      end

      # delete existing content if nil is sent
      if attrs[key_name].nil?
        if existing
          attrs["#{key_name}_attributes"] = { id: existing.id, _delete: true }
        end
        attrs.delete key_name

      elsif attrs[key_name].is_a?(Array)
        whitelisted_objs = attrs.delete(key_name).map do |nested_obj|
          whitelist! nested_obj, *fields
        end

        # Check if any existing objs are not in the array
        # If they aren't, ensure they get deleted
        if existing
          existing.each do |existing_obj|
            exists_in_whitelisted = whitelisted_objs.find { |wo| wo["id"] == existing_obj.id }

            unless exists_in_whitelisted
              whitelisted_objs.push(id: existing_obj.id, _delete: true)
            end
          end
        end

        attrs["#{key_name}_attributes"] = whitelisted_objs

      elsif attrs[key_name].is_a?(Hash)
        whitelisted_attrs = whitelist! attrs.delete(key_name), *fields
        whitelisted_attrs[:id] = existing.id if existing
        attrs["#{key_name}_attributes"] = whitelisted_attrs
      end
    end
  end
end
