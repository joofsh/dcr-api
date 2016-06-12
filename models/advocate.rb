require_relative './user'

class Advocate < User
  one_to_many :clients, class: :Client, key: :advocate_id

  def staff?
    true
  end

  def users_dataset
    clients_dataset
  end

  def validate
    validates_presence [:username]

    super
  end
end

