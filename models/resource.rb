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
