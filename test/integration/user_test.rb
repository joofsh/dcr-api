require_relative '../helper'

describe 'Users' do
  before do
    @advocate = Advocate.spawn!
    @client = Client.spawn! advocate: @advocate
    3.times { Client.spawn! advocate: @advocate }
  end

  describe 'GET /users/:id' do
    it 'requires token' do
      get "/users/#{@client.id}"

      assert_equal 403, status
    end

    it 'returns a user' do
      get user_url("/users/#{@client.id}", @advocate)

      assert_equal 200, status
      assert_equal @client.id, body[:id]
    end
  end

  describe 'GET /users' do
    it 'requires token' do
      get '/users'

      assert_equal 403, status
    end

    it 'returns paginated users' do
      get user_url('/users')

      assert_equal 200, status
      assert body.key? :users
      assert body.key? :count
      assert body.key? :length
      assert body.key? :start
    end

    it 'returns clients for an advocate' do
      get user_url('/users', @advocate)
      client = body[:users].first

      assert_equal 200, status
      assert 4, body[:count]
      assert @client.id, client[:id]
      assert @client.advocate_id, client[:advocate_id]
    end

    it 'does not return tags' do
      get user_url('/users', @advocate)

      assert_equal 200, status
      deny body[:users].first.key? :tags
    end

    it 'returns no users for a client token' do
      get user_url('/users', @client)
      assert_equal 200, status
      assert 0, body[:count]
    end
  end

  describe 'POST /users' do
    before do
      @attrs = {
        first_name: 'test',
        last_name: 'foo',
        username: 'test_user'
      }
    end

    it 'requires token' do
      post '/users'
      assert_equal 403, status
    end

    it 'errors with bad content' do
      post user_url('/users', @advocate), { user: {} }

      assert_equal 422, status
    end

    it 'creates a new user' do
      post user_url('/users', @advocate), { user: @attrs }

      assert_equal 201, status
      assert_equal @attrs[:username], body[:username]
      assert body.key? :id
    end

    it 'errors if user already exists' do
      post user_url('/users', @advocate), { user: @attrs }
      post user_url('/users', @advocate), { user: @attrs }

      assert_equal 422, status
    end

    it 'creates an address' do
      street = '1234 Main St'
      @attrs.merge!(mailing_address: { street: street })

      post user_url('users', @advocate), { user: @attrs }
      assert_equal 201, status
      assert_equal street, body[:mailing_address][:street]
    end
  end

  describe 'PUT /users' do
    before do
      @client = Client.spawn!
      @advocate = Advocate.spawn!
      @attrs = {
        first_name: 'new_first_name',
        email: 'new_email_address',
        mailing_address: {
          street: '12345 New St'
        }
      }
    end

    it 'requires token' do
      put "/users/#{@client.id}"
      assert_equal 403, status
    end

    it 'updates the user' do
      put user_url("/users/#{@client.id}", @advocate), { user: @attrs }

      assert_equal 200, status
      assert_equal @attrs[:email], body[:email]
      assert_equal @attrs[:mailing_address][:street], body[:mailing_address][:street]
    end
  end

  describe 'POST /users/authorize' do
    before do
      @advocate = Advocate.spawn!
      @advocate.update(password: 'test')
    end

    it 'errors on bad password' do
      post '/users/authorize', { identifier: @advocate.username, password: 'bad_pw' }
      assert_equal 403, status
    end

    it 'returns token on success' do
      post '/users/authorize', { identifier: @advocate.username, password: 'test' }
      assert_equal 200, status

      assert body.key? :token
      assert_equal @advocate.id, body[:id]
    end
  end
end
