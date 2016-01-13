class Token < Sequel::Model

  DEFAULT_TOKEN_TYPE = 'authenticate'

  def self.fetch(value)
    self.where(value: value).first
  end

  def self.find_or_create(id)
    token = self.where(user_id: id).first
    token ? token : self.create(user_id: id)
  end

  def before_create
    self.value = Shield::Password.generate_salt
    self.type = DEFAULT_TOKEN_TYPE unless self.type
  end

  def present
  end
end
