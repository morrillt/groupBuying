class Deal < ActiveRecord::Base
  include Geokit::Geocoders
  
  # Associations
  has_many :snapshots, :dependent => :destroy
  belongs_to :division
  belongs_to :site
  
  # Validations
  validates_presence_of :name
  validates_presence_of :permalink
  validates_presence_of :actual_price
  validates_presence_of :sale_price
  
  # Geocode lat lng if we have an address
  before_create :geocode_lat_lng, :unless => Proc.new{|d| d.raw_address.blank? }
  
  
  # Scopes
  scope :active, where(:active => true)
  
  # Instance Methods

  def revenue
    @revenue ||= (buyers_count.to_f * sale_price.to_f)
  end
  
  # Returns the latest snapshots sold_count value
  def buyers_count
    @buyers_count ||= snapshots.last.try(:sold_count).to_i
  end
  
  # Simply captures the snapshot data from the host
  # This method does not store anything
  # It is used to create snapshot records
  def capture_snapshot
    site.snapshooter.capture_deal(self)
  end
  
  # Currently only kind
  def currency
    "USD"
  end
  
  # Returns the site record through the last division
  # same for all
  def site
    @site ||= division.site
  end


  # Creates an actual mysql record
  # Captures the most recent data for a deal.
  # This is run every n hours and used to visualize the deals progress.
  def take_snapshot!
    snapshots.create!(:site_id => self.site_id)
  end
  
  private
  
  def geocode_lat_lng
    begin
      result = MultiGeocoder.geocode(raw_address.to_s)
      self.lat,self.lng = result.lat, result.lng
    rescue => e
      Rails.logger.error(e.message)
    end
  end
end
