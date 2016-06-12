module AuthHelpers
  def authenticate!
    fetch_current_user || forbidden!
  end

  def verify_current_user_or_staff!(user)
    @current_user.staff? ||
      user.id == @current_user.id ||
      forbidden!
  end

  def verify_staff!
    authenticate!
    current_user.staff? || forbidden!
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
    @current_user ||= fetch_current_user
  end

  def current_staff?
    current_user && current_user.staff?
  end

  private

  def fetch_current_user
    token = Token.fetch(token_value)
    @current_user = User[token.user_id] if token
  end
end
