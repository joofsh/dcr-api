require_relative '../lib/services/google_map'

class Address < Sequel::Model

  def to_s
    "#{street}#{street_2 ? " #{street_2}": nil}, #{city}, #{state} #{zipcode}"
  end

  def before_save
    location = Services::GoogleMap.geocode(self.to_s) rescue {}

    self.lat = location["lat"]
    self.lng = location["lng"]
  end
end
