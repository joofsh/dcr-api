require_relative '../helper'

describe "Resources" do
  before do
    @resource = Resource.spawn!
    3.times { Resource.spawn! }
  end

  describe 'GET /resources' do
    it 'does not require a token' do
      get '/resources'

      assert_equal 200, status
      assert_equal 4, body[:count]
      assert @resource.id, body[:resources].first[:id]
    end
  end

  describe 'POST /resources' do
    before do
      @attrs = {
        title: 'new title',
        phone: '917-314-3335'
      }
    end

    it 'does not require a token' do
      post '/resources', { resource: @attrs }
      assert_equal 201, status
    end

    it 'creates a resource' do
      post user_url('/resources'), { resource: @attrs }
      assert_equal 201, status
      assert_equal @attrs[:title], body[:title]
      assert body.key? :id
    end

    it 'errors with bad content' do
      post 'resources', { resource: {} }
      assert_equal 400, status
    end

    it 'creates an address' do
      street = '1234 Main St'
      @attrs.merge!(mailing_address: { street: street })

      post '/resources', { resource: @attrs }
    end
  end
end
