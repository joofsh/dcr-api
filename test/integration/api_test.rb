require_relative '../helper'

describe 'API' do
  before do

  end

  it 'returns 404 on unknown routes' do
    get '/jibberish_route'

    assert_equal 404, status
  end
end
