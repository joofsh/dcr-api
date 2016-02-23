class Question < Sequel::Model
  plugin :nested_attributes

  one_to_many :responses
  one_to_many :choices
  nested_attributes :choices
  presented_methods :choices

  add_association_dependencies choices: :destroy

  dataset_module do
    def for_client(id)
      self
    end
  end
end
