module AuthHelpers
  def authenticate!
    token = Token.fetch(token_value) || forbidden!
    @current_user = User[token.user_id] || forbidden!
  end

  def verify_current_user_or_staff!(user)
    @current_user.is_staff? ||
      user.id == @current_user.id ||
      forbidden!
  end

  def verify_staff!
    authenticate!
    @current_user.is_staff?
  end

  def token_value
    if auth_info = env["HTTP_AUTHORIZATION"]
      auth_type, auth_data =  auth_info.split(' ', 2)
      auth_type.downcase == 'bearer' && auth_data
    else
      params['token']
    end
  end

  def current_user
    @current_user
  end
end
