class Tag < Sequel::Model

  many_to_many :users
  many_to_many :resources
  many_to_many :choices

  def self.find_or_create(tag_name)
    self.where(name: tag_name).first || self.create(name: tag_name)
  end

  def before_validation
    self.weight ||= 0.5
  end

  def validate
    validates_presence [:name, :weight]
    validates_unique :name
  end
end
