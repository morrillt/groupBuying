class Geocode < ActiveRecord::Base
  include Geokit::Geocoders

  belongs_to :deal

  def self.geocode
    deals= Deal.where("created_at > ? AND active=1 AND lat NOT IN(0) AND lat IS NOT NULL AND lng NOT IN (0) AND lat IS NOT NULL", Time.now.advance(:days => -4)) \
      .limit(250) \
      .order("created_at DESC")
    deals.each do |d|
      result= MultiGeocoder.geocode(d.raw_address)
      self.create(:lat => result.lat, :lng => result.lng, :formatted_address => result.full_address, :deal_id => id)
    end
  end
end
