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
  before_create :geocode_lat_lng!, :unless => Proc.new{|d| d.raw_address.blank? }
  
  # Scopes
  scope :active, where(:active => true)
  
  before_save do
    self.hotness = calculate_hotness
  end
  
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
  
  # Returns current hotness rating based on snapshot counts
  def calculate_hotness
    if snapshots.count > 1
      snapshots.last.sold_count.to_i.percent_change_from( snapshots.first.sold_count )
    else
      0
    end
  end
  
  # Currently only kind
  def currency
    "USD"
  end
  
  # Returns the site record through the last division
  # same for all
  def site
    @site ||= division.try(:site)
  end
  
  def site_name
    @site_name ||= site.try(:name)
  end
  
  def division_name
    @division_name ||= division.try(:name)
  end


  # Creates an actual mysql record
  # Captures the most recent data for a deal.
  # This is run every n hours and used to visualize the deals progress.
  def take_snapshot!
    snapshots.create!(:site_id => self.site_id)
  end
  
  # Closes out the deal
  def close!
    self.active = false
    self.sold = true
    save
  end
  
  private
  
  def geocode_lat_lng!
    begin
      result = MultiGeocoder.geocode(raw_address.to_s)
      self.lat,self.lng = result.lat, result.lng
    rescue => e
      Rails.logger.error(e.message)
    end
  end
end
