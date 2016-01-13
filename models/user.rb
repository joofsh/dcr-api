class User < Sequel::Model
  include Shield::Model

  hidden_fields :crypted_password
  blacklisted_fields :crypted_password
  presented_methods :name

  plugin :single_table_inheritance,
    :role,
    model_map: {
      'patient' => :Patient,
      'therapist' => :Therapist,
      'admin' => :Admin
    }

  def self.fetch(identifier)
    self[identifier.to_i] ||
      self.where(email: identifier).first ||
      self.where(username: identifier).first
  end

  def is_staff?
    false
  end

  def name
    "#{first_name} #{last_name}"
  end

  def validate
    super

    validates_presence [:role, :username, :email]
    validates_unique :username, :email
  end

end
