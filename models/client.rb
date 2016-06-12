require_relative './user'

class Client < User
  many_to_one :advocate, class: :Advocate

  def users_dataset
    User.dataset.nullify
  end
end
