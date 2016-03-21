module Services
  class GoogleMap
    def self.mock_lat
      '123'
    end

    def self.mock_lng
      '543'
    end
    def self.geocode(address)
      {
        'lat' => mock_lat,
        'lng' => mock_lng
      }
    end
  end
end
