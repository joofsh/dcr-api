class Therapist < User
  one_to_many :sessions

  def is_staff?
    true
  end
end

