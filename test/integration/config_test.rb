require_relative '../helper'

describe 'Config' do
  before do
    @user_count = 2
    @resource_count = 3

    @user_count.times { Client.spawn! }
    @resource_count.times { Resource.spawn! }
  end

  describe 'GET /healthcheck' do
    it 'returns data counts' do
      get '/config/healthcheck'

      assert_equal 200, status
      assert_equal @user_count, body[:users]
      assert_equal @resource_count, body[:resources]
      assert_equal 0, body[:tokens]
    end
  end
end
