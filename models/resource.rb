class Resource < Sequel::Model
  plugin :nested_attributes

  many_to_many :tags
  many_to_one :address

  nested_attributes :address
  presented_methods :address, :tags

  add_association_dependencies address: :destroy

end
