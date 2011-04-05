require 'digest/md5'
class Deal < ActiveRecord::Base
  include Geokit::Geocoders
  CSV_FIELDS = %w[ id name permalink sale_price actual_price division_name site_name active hotness lat lng expires_at raw_address buyers_count ]
  
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
  before_create :geocode_lat_lng!, :unless => Proc.new{|d| d.raw_address.blank? || (d.lat && d.lng)}
  
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
    @has_more_than_one_snapshot ||= snapshots.to_a.count.to_i > 1
  end
  
  def calculate_hotness!
    if has_more_than_one_snapshot?
      period_snapshots = snapshots.to_a[-5..-1]
      initial_sold_count = snapshots.shift.try(:buyers_count).to_i
      total_increases_for_period = snapshots.map{|s| s.buyers_count - initial_sold_count }.sum
      rating = (total_increases_for_period.to_f / 5.0)
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
  
  def expired?
    Time.now >= expires_at
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
                                             
  # buyers_count == last_buyers_count
  def take_first_mongo_snapshot!
    DealSnapshot.create_from_deal!(self, true)
  end
  
  # Closes out the deal
  def close!
    self.active = false
    self.sold = true
    save
  end

  def self.overall_trending(limit = 10)
    count_trending_by_date_range(Time.now - 5.hours, Time.now, limit)
  end

  def self.current_revenue_trending(limit = 10)
    revenue_trending_by_date_range(Time.now - 5.hours, Time.now, limit)
    # trending = Deal.revenue_trending_by_hour(now, now.hour)
    # deals = Deal.find(trending.values).map{|deal| 
    #   deal.trending_order = trending.select{|k,v|
    #     v == deal.id
    #   }.first
    #   deal
    # }
    # 
    # deals.sort_by(&:trending_order)
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
    Deal.select("id, sale_price").find_all_by_id(buyers.keys).map {|deal|
      snapshot_deals[deal.id] = deal.sale_price
    }                 
    
    revenue_trending_deals = {}
    snapshot_deals.collect {|deal_id, sale_price|
      revenue_trending_deals[(deal_id * buyers[deal_id]).to_f] = deal_id
    }
    revenue_trending_deals
  end

  def self.revenue_trending_by_date_range(from, to, limit=25)
    start_at = Time.parse("#{from.year}-#{from.month}-#{from.day} #{from.hour}:00:00").utc
    end_at   = Time.parse("#{to.year}-#{to.month}-#{to.day} #{to.hour}:00:00").utc
    snapshots = DealSnapshot.by_date_range(start_at, end_at)

    buyers= {}
    snapshots.each do |s|
      buyers[s.deal_id] ||=0
      buyers[s.deal_id] += s.buyers_count - s.last_buyers_count
    end                                       
    
    # Get Deals prices
    snapshot_deals = {}
    deals = Deal.find_all_by_id(buyers.keys).map {|deal|
      deal.trending_order = -(deal.sale_price * buyers[deal.id])
      deal
    }                 
    
    deals.sort_by(&:trending_order)[0..limit]
  end   
  
  def self.count_trending_by_date_range(from, to, limit=25)
    start_at = Time.parse("#{from.year}-#{from.month}-#{from.day} #{from.hour}:00:00").utc
    end_at   = Time.parse("#{to.year}-#{to.month}-#{to.day} #{to.hour}:00:00").utc
    snapshots = DealSnapshot.by_date_range(start_at, end_at)

    buyers_count= {}
    snapshots.each do |s|
      buyers_count[s.deal_id] ||=0
      buyers_count[s.deal_id] += s.buyers_count - s.last_buyers_count
    end           

    deals = Deal.find_all_by_id(buyers_count.keys).collect{|deal| 
      deal.trending_order = - buyers_count[deal.id]
      deal
    }
    deals.sort_by(&:trending_order)[0..limit]
  end 
  
  
  class << self
    def export(query)
      FasterCSV.generate do |csv|
        Deal.where(query).map { |r| CSV_FIELDS.map { |m| r.send m }  }.each { |row| csv << row }
      end
    end
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
