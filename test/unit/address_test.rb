require_relative '../helper'
require_relative '../services/google_map'

describe Address do

  it "sets lat & lng on save" do
    address = Address.spawn
    deny address.lat
    deny address.lng

    assert address.save
    assert_equal Services::GoogleMap.mock_lat, address.lat
    assert_equal Services::GoogleMap.mock_lng, address.lng
  end
end
