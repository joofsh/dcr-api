class Question < Sequel::Model
  plugin :paranoid, enable_default_scope: true, deleted_column_default: Time.at(0)
  plugin :nested_attributes

  # Note: the order categories show up in this array is the order they will appear in
  # the client question wizard
  CATEGORIES = ['General', 'Demographic', 'Education', 'Employment', 'Family', 'Health',
                'Housing', 'Legal', 'Mental Health', 'Substance Use']

  DEFAULT_CATEGORY = CATEGORIES.first

  one_to_many :responses
  one_to_many :choices
  nested_attributes :choices, destroy: true
  presented_methods :choices

  add_association_dependencies choices: :destroy

  dataset_module do
    def for_client(id)
      self
    end

    def order_by_category
      cases = CATEGORIES.map.with_index do |category, index|
        [category, index]
      end

      order_prepend(Sequel.asc(Sequel.case(cases, 999, :category)))
    end

    def order_by_order
      order_prepend(Sequel.asc(:order, nulls: :last))
    end

    def ordered
      order_by_order.order_by_category
    end
  end

  def before_validation
    self.category ||= DEFAULT_CATEGORY
  end

  def validate
    validates_presence [:stem, :category]
    validates_includes CATEGORIES, :category
  end
end
