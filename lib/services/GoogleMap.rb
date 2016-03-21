require 'httparty'

module Services
  class GoogleMap
    BASE_URL = "https://maps.googleapis.com/maps/api/geocode/json"
    GOOGLE_MAPS_API_KEY = ENV["GOOGLE_MAPS_API_KEY"]

    def geocode(address)
      resp = HTTParty.get(BASE_URL, {
        query: {
          address: address,
          key: GOOGLE_MAPS_API_KEY
        }
      })
      resp["results"].first["geometry"]["location"]
    end
  end
end
