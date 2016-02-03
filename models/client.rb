require_relative './user'

class Client < User
  many_to_one :advocate, class: :Advocate
end
