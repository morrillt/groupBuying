class Geocode < ActiveRecord::Base
  include Geokit::Geocoders

  belongs_to :deal

  def self.geocode
    deals= Deal.where("created_at > ? AND active=1 AND lat NOT IN(0) AND lat IS NOT NULL AND lng NOT IN (0) AND lat IS NOT NULL", Time.now.advance(:days => -5)) \
      .order("created_at DESC").group("raw_address")
    deals.each do |d|
      if (d.raw_address)
        result= GoogleGeocoder.geocode(d.raw_address)
        if result.lat && result.lng
          self.create(:lat => result.lat, :lng => result.lng, :formatted_address => result.full_address, :deal_id => d.id)
        end
      end
    end
  end
end
