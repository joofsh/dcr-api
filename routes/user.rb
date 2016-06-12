class UserRoutes < EhrApiBase
  route do |r|
    r.post 'authorize' do
      user = User.authenticate(params[:identifier], params[:password]) || forbidden!
      token = Token.find_or_create(user.id)

      user.present(params).merge(token: token.value)
    end

    r.post 'guests' do
      presented_guest = create! Guest
      token = Token.find_or_create(presented_guest[:id])

      presented_guest.merge(token: token.value)
    end

    authenticate!

    r.on ':id' do |user_id|
      user = User[user_id] || not_found!

      r.get do
        user.present(params)
      end

      r.put do
        verify_current_user_or_staff!(user)
        update! user, user_attributes, User
      end
    end

    r.get do
      paginated(:users, current_user.users_dataset)
    end

    r.post do
      create! User, user_attributes
    end
  end

  def user_attributes
    attrs = params[:user] || bad_request!
    whitelist!(attrs, :first_name, :last_name, :role, :advocate_id, :birthdate, :gender,
               :sexual_orientation, :phone, :email, :username, :hive_postiive, :language,
               :race, :mailing_address, :home_address)

    rename_nested_attributes!('mailing_address', attrs, User, params[:id],
                              :street, :street_2, :city, :state, :zipcode)
    rename_nested_attributes!('home_address', attrs, User, params[:id],
                              :street, :street_2, :city, :state, :zipcode)
    attrs
  end
end

