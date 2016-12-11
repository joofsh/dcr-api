require_relative '../helper'

describe Resource do
  it 'allows saving array of categories' do
    resource = Resource.spawn!
    deny resource.category
    arr = ['Cat 1', 'Cat 2', 'Cat 3']

    resource.update(category: arr)
    assert resource.reload.category.to_a.is_a?(Array)
    assert_equal arr, resource.category.to_a
  end

  describe '.sorted_by_descriptor_weight' do
    before do
      descriptor_tags = 3.times.map do |i|
        Tag.spawn! type: 'Descriptor', weight: (i * 20 + 20)
      end
      @service_tag = Tag.spawn! type: 'Service'
      service_tag_2 = Tag.spawn! type: 'Service'

      @resources = Array.new(3) { Resource.spawn! }
      @resources.each_with_index do |r, i|
        r.add_tag(@service_tag)

        # Add 2 descriptor tags
        r.add_tag(descriptor_tags[i])

        t = descriptor_tags[i + 1]
        r.add_tag(t) if t
      end

      # These are resources that match the service tag
      # but no descriptors
      @resources2 = Array.new(2) { Resource.spawn! }
      @resources2.each { |r| r.add_tag(@service_tag) }

      other_resources = Array.new(3) { Resource.spawn! }
      other_resources.each_with_index do |r, i|
        r.add_tag(service_tag_2)

        # Add 2 descriptor tags
        r.add_tag(descriptor_tags[i])

        t = descriptor_tags[i + 1]
        r.add_tag(t) if t
      end
    end

    it 'filters to resources associated with the tag' do
      resources = Resource.sorted_by_descriptor_weight(@service_tag).all
      ids = resources.map(&:id)

      assert_equal 5, resources.count
      (@resources + @resources2).each do |r|
        assert ids.include?(r.id)
      end
    end

    it 'orders them by ranking' do
      resources = Resource.sorted_by_descriptor_weight(@service_tag).all
      assert_equal 100, resources[0][:ranking]
      assert_equal 60, resources[1][:ranking]
      assert_equal 60, resources[2][:ranking]
      assert_equal 0, resources[3][:ranking]
      assert_equal 0, resources[4][:ranking]
    end
  end
end
