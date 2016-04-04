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

    it 'filters by published if non-staff' do
      @resource.unpublish!
      assert_equal 3, Resource.published.count
      get user_url('/resources', Client.spawn!)

      assert_equal 200, status
      assert_equal 3, body[:count]
    end

    it 'filters by published if not authed' do
      @resource.unpublish!
      assert_equal 3, Resource.published.count
      get '/resources'

      assert_equal 200, status
      assert_equal 3, body[:count]
    end

    it 'returns all resources if staff' do
      @resource.unpublish!
      assert_equal 3, Resource.published.count
      get user_url('/resources', Advocate.spawn!)

      assert_equal 200, status
      assert_equal 4, body[:count]
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

  describe 'Publishing' do
    it 'requires auth' do
      put "/resources/#{@resource.id}/publish"
      assert_equal 403, status

      put "/resources/#{@resource.id}/unpublish"
      assert_equal 403, status
    end

    it 'publishes' do
      put user_url("/resources/#{@resource.id}/publish", Advocate.spawn!)
      assert_equal 200, status
      assert @resource.reload.published
    end

    it 'unpublishes' do
      put user_url("/resources/#{@resource.id}/unpublish", Advocate.spawn!)
      assert_equal 200, status
      deny @resource.reload.published
    end
  end
end
