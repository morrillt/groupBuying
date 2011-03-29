require 'digest/md5'
class Deal < ActiveRecord::Base
  include Geokit::Geocoders
  
  attr_accessor :trending_order
  
  # Associations
  belongs_to :division
  belongs_to :site
  
  # Validations
  validates_presence_of :name
  validates_presence_of :permalink
  validates_presence_of :actual_price
  validates_presence_of :sale_price
  validates_presence_of :expires_at
  validates_uniqueness_of :deal_id, :scope => :site_id
  validates_uniqueness_of :permalink, :scope => :site_id
  
  # Geocode lat lng if we have an address
  before_create :geocode_lat_lng!, :unless => Proc.new{|d| d.raw_address.blank? }
  
  before_create do
    self.deal_id = Digest::MD5.hexdigest(name + permalink + expires_at.to_s) unless self.deal_id.present?
  end
  
  before_destroy do
    snapshots = DealSnapshot.where(:deal_id => self.id)
    snapshots.destroy_all
  end
  
  # Scopes
  scope :active, where(:active => true)
  scope :inactive, where(:active => false)
  scope :expired, where("expires_at IS NOT NULL AND expires_at < NOW()")
  scope :by_site, lambda{|site_id| where(:site_id => site_id)}
  
  # Instance Methods

  def snapshots
    @snapshots ||= DealSnapshot.where(:deal_id => self.id)
  end

  # returns true if more than one snapshot for deal
  def has_more_than_one_snapshot?
    @has_more_than_one_snapshot ||= snapshots.count.to_i > 1
  end
  
  def calculate_hotness!
    if has_more_than_one_snapshot?
      first_snapshot_sold_count = snapshots.first.buyers_count
      rating = buyers_count.to_i.percent_change_from( first_snapshot_sold_count.to_i )
      update_attribute(:hotness, rating)
    else
      true
    end
  end
  
  def revenue
    @revenue ||= (buyers_count.to_f * sale_price.to_f)
  end
  
  # Returns the latest snapshots sold_count value
  def buyers_count
    @buyers_count ||= snapshots.last.try(:buyers_count).to_i
  end
  
  # Simply captures the snapshot data from the host
  # This method does not store anything
  # It is used to create snapshot records, 
  # and returns the current sold count for the deal
  def capture_sold_count
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


  # DEPRECIATED
  # Creates an actual mysql record
  # Captures the most recent data for a deal.
  # This is run every n hours and used to visualize the deals progress.
  def take_snapshot!
    snapshots.create!(:site_id => self.site_id)
  end
  
  # replaces take_snapshot!
  def take_mongo_snapshot!
    DealSnapshot.create_from_deal!(self)
  end
  
  # Closes out the deal
  def close!
    self.active = false
    self.sold = true
    save
  end

  def self.overall_trending(limit=5)
    # Deal.find(:all, :order => "hotness", :limit => limit)
    # Deal.find(:all, :include => :site, :order => "hotness DESC", :limit => limit)
    date= Time.now
    Deal.find_by_sql ["SELECT deals.id, deals.name, sites.source_name AS source_name, deals.permalink FROM deals, sites WHERE deals.site_id = sites.id AND deals.active = 1 GROUP BY permalink ORDER BY hotness DESC LIMIT ?", limit]
  end

  def self.current_revenue_trending
    now= Time.now
    trending = Deal.revenue_trending_by_hour(now, now.hour)
    deals = Deal.find(trending.values).map{|deal| 
      deal.trending_order = trending.select{|k,v|
        v == deal.id
      }.first
      deal
    }
    
    deals.sort_by(&:trending_order)
  end

  def self.revenue_trending_by_hour(date, hour, limit=25)
    if hour.to_i < 10
      hour = "0#{hour}"
    end              
    start_at = Time.parse("#{date.year}-#{date.month}-#{date.day} #{hour}:00:00").utc
    end_at   = Time.parse("#{date.year}-#{date.month}-#{date.day} #{hour}:59:59").utc
    snapshots = DealSnapshot.by_date_range(start_at, end_at)

    buyers= {}
    snapshots.each do |s|
      buyers[s.deal_id] = s.buyers_count - s.last_buyers_count
    end                                   
    
    # Get Deals prices
    snapshot_deals = {}
    Deal.select("id, sale_price").find(buyers.keys).map {|deal|
      snapshot_deals[deal.id] = deal.sale_price
    }                 
    
    revenue_trending_deals = {}
    snapshot_deals.collect {|deal_id, sale_price|
      revenue_trending_deals[(deal_id * buyers[deal_id]).to_f] = deal_id
    }
    revenue_trending_deals
  end


  private
  def geocode_lat_lng!
    begin
      result = MultiGeocoder.geocode(raw_address.to_s)
      self.lat,self.lng = result.lat, result.lng
    rescue => e
      # Rails.logger.error(e.message)
    end
  end
end
