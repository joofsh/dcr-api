require_relative './user'

class Patient < User
  one_to_many :sessions
end
