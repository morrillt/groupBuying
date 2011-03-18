class Deal < ActiveRecord::Base
#  include Geokit::Geocoders
  
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

  def self.get_info(site)
    data = Hash.new 
    #active deals
    data[:tracked_active] = self.find(:all, :conditions => {:site_id =>  site.id, :active => true }).length
    
    # deals tracked to date
    data[:deals_tracked] = self.find(:all,:conditions => {:site_id => site.id}).length
    
    #coupones purchased to date
    # data[:coupon_purchased] = 0

    #total revenue to date
    # data[:total_revenue]

    #avg revenue per deal
    # data[:avg_deal]
    
    # locations per site   

    
    # deal closed today
    data[:closed_today] = self.find_by_sql("SELECT COUNT(DISTINCT(deal_id)) as closed FROM deals WHERE active=0 AND DATE(created_at)=DATE(NOW()) and site_id = "+site.id.to_s).first.closed
    
    #deals closed yesterday
    data[:closed_yesterday] = self.find_by_sql("SELECT COUNT(DISTINCT(deal_id)) as closed FROM snapshots WHERE status=0 AND DATE(created_at)=DATE_SUB(DATE(NOW()), INTERVAL 1 DAY) and site_id ="+site.id.to_s).first.closed

    #deals closed this week
    data[:closed_week] = self.find_by_sql("SELECT COUNT(DISTINCT(deal_id)) as closed FROM snapshots WHERE status=0 AND DATE(created_at)>=DATE_SUB(DATE(NOW()), INTERVAL 8 DAY) AND DATE(created_at)<=DATE(NOW()) and site_id = "+ site.id.to_s).first.closed

    #coupons purchased today
    data[:purchased_today] = self.find_by_sql("select sum(sold_since_last_snapshot_count) as nsold from snapshots where DATE(created_at)=DATE(NOW()) and site_id = " + site.id.to_s).first.nsold.to_i

    #coupons purchased yesterday
    data[:purchased_yesterday] = self.find_by_sql("select sum(sold_since_last_snapshot_count) as nsold from snapshots where DATE(created_at)=DATE_SUB(DATE(NOW()), INTERVAL 1 DAY) and site_id = " + site.id.to_s).first.nsold.to_i

    #coupons purchased week
    data[:purchased_week] = self.find_by_sql("select sum(sold_since_last_snapshot_count) as nsold from snapshots where DATE(created_at)>=DATE_SUB(DATE(NOW()), INTERVAL 7 DAY) and DATE(created_at)<=DATE(NOW()) and site_id = " + site.id.to_s).first.nsold.to_i
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
