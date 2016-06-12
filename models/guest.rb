require_relative './user'

class Guest < User
  # A list of fields we forbid setting for guest users
  FORBIDDEN_FIELDS =  ['first_name', 'last_name', 'email', 'birthdate', 'password',
                       'race', 'home_address', 'mailing_address', 'sexual_orientation',
                       'gender', 'phone', 'language', 'hiv_positive', 'advocate_id']

  def users_dataset
    User.dataset.nullify
  end

  def guest?
    true
  end

  def before_save
    super

    FORBIDDEN_FIELDS.each do |field|
      self.set(field => nil)
    end
  end

end
