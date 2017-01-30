class Question < Sequel::Model
  plugin :paranoid, enable_default_scope: true, deleted_column_default: Time.at(0)
  plugin :nested_attributes

  # Note: the order categories show up in this array is the order they will appear in
  # the client question wizard
  CATEGORIES = ['Initial', 'General', 'Demographic', 'Education', 'Employment', 'Family', 'Health',
                'Housing', 'Legal', 'Mental Health', 'Substance Use']

  DEFAULT_CATEGORY = CATEGORIES[1] # General

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

    def ordered_by_created_at
      order_prepend(Sequel.asc(:created_at))
    end

    def ordered_for_wizard
      order_by_order.order_by_category
    end

    def exclude_answered_by(user)
      answered_ids = user.responses_dataset.select(:question_id)
      exclude(id: answered_ids)
    end

    def current_for_user(user)
      response = user.responses_dataset.last

      question = if response && response.choice.next_question
        response.choice.next_question
      else
        exclude_answered_by(user).ordered_for_wizard.first
      end
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
