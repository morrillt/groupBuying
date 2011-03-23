require 'digest/md5'
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
  validates_uniqueness_of :deal_id
  validates_uniqueness_of :name, :scope => :deal_id
  
  # Geocode lat lng if we have an address
  before_create :geocode_lat_lng!, :unless => Proc.new{|d| d.raw_address.blank? }
  
  before_create do
    self.deal_id = Digest::MD5.hexdigest(name + permalink + expires_at.to_s)
  end
  
  # Scopes
  scope :active, where(:active => true)
  scope :inactive, where(:active => false)
  scope :expired, where("expires_at IS NOT NULL AND expires_at < NOW()")
  
  # Instance Methods

  # returns true if more than one snapshot for deal
  def has_more_than_one_snapshot?
    @has_more_than_one_snapshot ||= snapshots.count.to_i > 1
  end
  
  def calculate_hotness!
    if has_more_than_one_snapshot?
      first_snapshot_sold_count = snapshots.first.sold_count
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

  #Yep, I know this is not the most beatiful thing... 
  def self.get_info(site)
    data = Hash.new 
    #active deals
    data[:tracked_active] = self.find(:all, :conditions => {:site_id =>  site.id, :active => true }).length
    
    # deals tracked to date
    data[:deals_tracked] = self.find(:all,:conditions => {:site_id => site.id}).length
    
    #coupones purchased to date
    data[:coupon_purchased] = self.find_by_sql("select sum(c) as purchased from (SELECT deal_id, MAX(sold_count) AS c FROM snapshots where site_id = #{site.id} GROUP BY deal_id order by deal_id desc) x;").first.purchased.to_i

    #total revenue to date
    data[:total_revenue] = self.find_by_sql("select sum(c) as rev from(SELECT MAX(sold_count) * sale_price  AS c, snapshots.site_id FROM snapshots LEFT JOIN deals on snapshots.deal_id=deals.id where deals.site_id = #{site.id} GROUP BY snapshots.deal_id ) x;").first.rev.to_i

    #average coupon sold per deal
    data[:avg_coupon] = self.find_by_sql("select avg(sold) as coupon_sold from (select distinct(snapshots.deal_id),max(sold_count) as sold from snapshots left join deals on deals.id = snapshots.deal_id where deals.site_id = #{site.id}) x;").first.coupon_sold.to_f

    #average price per deal
    data[:price_deal] = self.find_by_sql("select avg(sale_price) as price from deals where site_id = #{site.id};").first.price.to_f

    #avg revenue per deal
    data[:avg_deal] = self.find_by_sql("select avg(c) as prom from (SELECT MAX(sold_count) * sale_price  AS c FROM snapshots LEFT JOIN deals on snapshots.deal_id=deals.id where deals.site_id = #{site.id} GROUP BY snapshots.deal_id ) x;").first.prom.to_f
    
    # deal closed today
    data[:closed_today] = self.find_by_sql("SELECT COUNT(DISTINCT(deals.id)) as closed FROM snapshots LEFT JOIN deals on snapshots.deal_id=deals.id WHERE active=0 and deals.id = #{site.id} AND DATE(snapshots.created_at)>=DATE_SUB(DATE(NOW()), INTERVAL 8 DAY) AND DATE(snapshots.created_at)<=DATE(NOW())").first.closed
    
    #deals closed yesterday
    data[:closed_yesterday] = self.find_by_sql("SELECT COUNT(DISTINCT(deal_id)) as closed FROM snapshots WHERE status=0 AND
    DATE(created_at)=DATE_SUB(DATE(NOW()), INTERVAL 1 DAY) and site_id = #{site.id}").first.closed

    #deals closed this week
    data[:closed_week] = self.find_by_sql("SELECT COUNT(DISTINCT(deals.id)) as closed FROM snapshots LEFT JOIN deals on snapshots.deal_id=deals.id WHERE active=0 and deals.site_id = #{site.id} AND DATE(snapshots.created_at)>=DATE_SUB(DATE(NOW()), INTERVAL 8 DAY) AND DATE(snapshots.created_at)<=DATE(NOW());").first.closed

    #coupons purchased today
    data[:purchased_today] = self.find_by_sql("select sum(sold_since_last_snapshot_count) as nsold from snapshots where
    DATE(created_at)=DATE(NOW()) and site_id = #{site.id}").first.nsold.to_i

    #coupons purchased yesterday
    data[:purchased_yesterday] = self.find_by_sql("select sum(sold_since_last_snapshot_count) as nsold from snapshots where DATE(created_at)=DATE_SUB(DATE(NOW()), INTERVAL 1 DAY) and site_id = #{site.id}").first.nsold.to_i

    #coupons purchased week
    data[:purchased_week] = self.find_by_sql("select sum(sold_since_last_snapshot_count) as nsold from snapshots where DATE(created_at)>=DATE_SUB(DATE(NOW()), INTERVAL 8 DAY) and DATE(created_at)<=DATE(NOW()) and site_id = #{site.id}").first.nsold.to_i

    #revenue today
    data[:revenue_today] = self.find_by_sql("select sum(c) as prom from (SELECT MAX(sold_count) * sale_price  AS c FROM snapshots LEFT JOIN deals on snapshots.deal_id=deals.id WHERE deals.site_id = #{site.id} and DATE(snapshots.created_at) = DATE(NOW()) GROUP BY snapshots.deal_id ) x;").first.prom.to_i
    
    #revenue yesterday
    data[:revenue_yesterday] = self.find_by_sql("select sum(c) from (SELECT MAX(sold_count) * sale_price  AS c FROM snapshots LEFT JOIN deals on snapshots.deal_id=deals.id WHERE deals.site_id = #{site.id} and DATE(snapshots.created_at) = DATE_SUB(DATE(NOW()), INTERVAL 1 DAY) GROUP BY snapshots.deal_id ) x;")

    #avg revenue today
    data[:avg_revenue_today] = self.find_by_sql("select avg(c) as avg_revenue_today from (SELECT MAX(sold_count) * sale_price  AS c FROM snapshots LEFT JOIN deals on snapshots.deal_id=deals.id WHERE deals.site_id = 1 and DATE(snapshots.created_at)=date(now()) GROUP BY snapshots.deal_id ) x;").first.avg_revenue_today.to_f

    #avg revenue yesterday
    data[:avg_revenue_yesterday] = self.find_by_sql("select avg(c) from (SELECT MAX(sold_count) * sale_price  AS c FROM snapshots LEFT JOIN deals on snapshots.deal_id=deals.id WHERE deals.site_id = 1 and DATE(snapshots.created_at)=DATE_SUB(DATE(NOW()), INTERVAL 1 DAY) GROUP BY snapshots.deal_id ) x;")

    ###changes in %
    # coupons closed today-yesterday    
    unless data[:closed_yesterday]==0
      data[:change_today_yesterday] = (data[:closed_today] - data[:closed_yesterday])/data[:closed_yesterday]
    else
      data[:change_today_yesterday] = "No data"
    end

    # coupons closed today-yesterday
    tmp = self.find_by_sql("SELECT COUNT(DISTINCT(deal_id)) as closed FROM snapshots WHERE status=0 and DATE(created_at)>=DATE_SUB(DATE(NOW()), INTERVAL 2 DAY) and DATE(created_at)<=DATE_SUB(DATE(NOW()), INTERVAL 1 DAY) and site_id = #{site.id}").first.closed

    unless tmp==0
      data[:change_yesterday] = (data[:closed_yesterday] - tmp )/tmp
    else
      data[:change_yesterday] = "No data"
    end

    # coupons change today-yesterday
    unless data[:purchased_today]==0
      data[:purchased_change_today] = if(data[:purchased_yesterday] == 0) 
        data[:purchased_today]
      else
        (data[:purchased_today].to_i - data[:purchased_yesterday].to_i) / data[:purchased_yesterday]
      end
    else
      data[:purchased_change_today] = "No data"
    end

    # coupons change yesterday-
    tmp = self.find_by_sql("select sum(sold_since_last_snapshot_count) as nsold from snapshots where DATE(created_at)>=DATE_SUB(DATE(NOW()), INTERVAL 2 DAY) and DATE(created_at)<=DATE_SUB(DATE(NOW()), INTERVAL 1 DAY) and site_id = #{site.id}").first.nsold.to_i

    unless tmp==0
      data[:change_purchased_yesterday] = (data[:purchased_yesterday] - tmp )/tmp
    else
      data[:change_purchased_yesterday] = "No data"
    end

    return data
  end

  def self.overall_trending(limit=5)
    Deal.find(:all, :order => "hotness", :limit => limit)
  end

  def self.current_revenue_trending
    now= Time.now
    Deal.revenue_trending_by_hour(now, now.hour)
  end

  def self.revenue_trending_by_hour(date, hour, limit=25)
    Deal.find_by_sql ["SELECT deals.id, deals.name, deals.permalink, (snapshots.sold_count*deals.sale_price) AS revenue FROM snapshots, deals WHERE snapshots.deal_id = deals.id AND YEAR(snapshots.created_at) = ? AND MONTH(snapshots.created_at) = ? AND DAY(snapshots.created_at) = ? AND HOUR(snapshots.created_at) = ? GROUP BY permalink ORDER BY revenue DESC LIMIT ?", date.year, date.month, date.day, hour, limit]
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
