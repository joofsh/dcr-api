class Resource < Sequel::Model
  plugin :nested_attributes

  many_to_many :tags
  many_to_one :address

  nested_attributes :address
  presented_methods :address

  add_association_dependencies address: :destroy

  dataset_module do
    def published
      where(published: true)
    end
  end

  def extend_present
    {
      tags: tags.map(&:name)
    }
  end

  def publish!
    update(published: true)
  end

  def unpublish!
    update(published: false)
  end
end
