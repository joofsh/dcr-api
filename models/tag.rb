class Tag < Sequel::Model

  many_to_many :users
  many_to_many :resources
  many_to_many :choices

  TYPES = %w(Service Descriptor)
  DEFAULT_TYPE = TYPES[1] # Descriptor

  WEIGHT_RANGE = (0..100)

  dataset_module do
    def with_details
      eager(:choices, :resources)
    end

    def order_by_type
      cases = TYPES.map.with_index do |category, index|
        [category, index]
      end

      order_prepend(Sequel.asc(Sequel.case(cases, 999, :type)))
    end

    def order_by_weight
      order_prepend(Sequel.desc(:weight, nulls: :last))
    end

    def ordered
      order_by_weight.order_by_type
    end

    def service
      where(type: TYPES[0]) # Service
    end
  end

  def self.find_or_create(tag_name)
    self.where(name: tag_name).first || self.create(name: tag_name)
  end

  def before_validation
    self.weight ||= 50
    self.type ||= DEFAULT_TYPE
  end

  def validate
    validates_presence [:name, :weight, :type]
    validates_unique :name
    validates_includes TYPES, :type
    validates_numeric :weight

    errors.add(:weight, 'is not in range') unless WEIGHT_RANGE.include?(weight)
  end

  def present(options = {})
    obj = super
    if !!options[:details]
      obj.merge!(
        choices: choices.map { |c| c.present },
        resources: resources.map { |c| c.present }
      )
    end

    obj
  end
end
