class Resource < Sequel::Model
  plugin :association_pks
  plugin :nested_attributes

  many_to_many :tags, delay_pks: true
  many_to_one :address

  nested_attributes :address, destroy: true
  presented_methods :address, :tags

  add_association_dependencies address: :destroy,
                               tags: :nullify

  dataset_module do
    def published
      where(published: true)
    end

    def sorted_by_descriptor_weight(service_tag)
      resource_ids = service_tag.resources_dataset.select(:id)

      left_join(:resources_tags, resource_id: :resources__id)
        .left_join(:tags, tags__id: :tag_id, tags__type: 'Descriptor')
        .where(resources__id: resource_ids)
        .select_all(:resources)
        .group_by(:resources__id)
        .select_append(
          Sequel.function(:coalesce, Sequel.function(:sum, :weight), 0).as(:ranking)
        ).order(Sequel.desc(:ranking), :resources__id)
    end
  end

  def publish!
    update(published: true)
  end

  def unpublish!
    update(published: false)
  end

  def validate
    validates_presence [:title]
  end
end
