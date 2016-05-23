class Question < Sequel::Model
  plugin :nested_attributes

  one_to_many :responses
  one_to_many :choices
  nested_attributes :choices, destroy: true
  presented_methods :choices

  add_association_dependencies choices: :destroy

  dataset_module do
    def for_client(id)
      self
    end

    def ordered
      order_by(Sequel.asc(:order, nulls: :last))
    end
  end

  def validate
    validates_presence [:stem]
  end
end
