class Site < ActiveRecord::Base
  has_many :snapshots, :dependent => :destroy
  has_many :deals, :through => :divisions
  has_many :divisions, :dependent => :destroy
  has_many :hourly_revenue_by_site

  scope :active, where(:active => true)
  
  # Updates all the sites active deals buy createing
  # snapshots of the deal
  def update_snapshots!
    deals.active.each do |deal|
      # record the deal into mongodb as DealSnapshot
      deal.take_mongo_snapshot!
    end
  end
  
  # Captures new deals in the database
  def crawl_new_deals
    snapshooter.crawl_new_deals!
  end
  
  # Returns a new instance of the Site Snapshooter class
  # Example:
  #  Snapshooter::KgbDeals.new
  def snapshooter
    @snapshooter ||= case self.source_name
    when 'kgb_deals'
      Snapshooter::KgbDeals.new
    when 'travel_zoo'
      Snapshooter::TravelZoo.new
    when 'homerun'
      Snapshooter::Homerun.new
    when 'open_table'
      Snapshooter::OpenTable.new
    when 'groupon'
      Snapshooter::GrouponClass.new
    else
      raise Exception, "Unknown site source_name #{self.source_name}"
    end
  end

  # Returns the total revenue for all active deals of this site
  # for a given hour of a given date. 
  def revenue_by_given_hour_and_date(hour, date)
    if hour.to_i < 10
      hour = "0#{hour}"
    end
    puts "revenue_by_given_hour_and_date(#{hour},#{date})"
    #snapshots= Snapshot.find_by_sql ["SELECT snapshots.deal_id, SUM(sold_since_last_snapshot_count) AS total_count, deals.sale_price FROM snapshots, deals WHERE snapshots.site_id = ? AND YEAR(snapshots.created_at) = ? AND MONTH(snapshots.created_at) = ? AND DAY(snapshots.created_at) = ? AND HOUR(snapshots.created_at) = ? AND sold_since_last_snapshot_count NOT IN (0) AND snapshots.deal_id = deals.id GROUP BY deal_id", self.id, date.year, date.month, date.day, hour]
    start_at = Time.parse("#{date.year}-#{date.month}-#{date.day} #{hour}:00:00").utc
    end_at   = Time.parse("#{date.year}-#{date.month}-#{date.day} #{hour}:59:59").utc
    snapshots = DealSnapshot.by_date_range(start_at, end_at, :site_id => self.id)
    puts "Snapshots: #{snapshots.count}"
    revenue= 0
    snapshots.each do |s|
      revenue += (s.buyers_count.to_f * s.price.to_f)
    end
    revenue.to_f
  end

  # Returns the total revenue for each division of this site
  # within the given hour of the given date
  def revenue_for_all_divisions_by_given_hour_and_date(hour, date)
    start_at = Time.parse("#{date.year}-#{date.month}-#{date.day} #{hour}:00:00")
    snapshots = DealSnapshot.by_date_range(start_at, (start_at + 59.minutes), :site_id => self.id)
    revenues = {}
    snapshots.each do |s|
      revenues[s.division_id] ||= 0
      revenues[s.division_id] += (s.buyers_count.to_f * s.price.to_f)
    end
    revenues
  end      
   
  # ================================== TODO FIXME ======================================
  # ========================== Change to map-reduce functions ==========================
  
  def coupon_purchased
    DealSnapshot.only(:deal_id).where({:site_id => self.id}).group.collect{|group| group["group"].collect(&:buyers_count).max}.sum
  end   
                      
  # TODO: FIXME: active == 1 ??
  def total_revenue                     
    deals = {}                                                                                                                
    Deal.where(:site_id => self.id).each {|d| deals[d.id] = d.sale_price}
    DealSnapshot.only(:deal_id).where({:site_id => self.id}).group.collect{|group| deals[group["deal_id"].to_i] * group["group"].max(&:buyers_count).buyers_count }.sum
  end 
  
  def avg_coupon
    sold = DealSnapshot.only(:deal_id).where({:site_id => 1}).group.collect{|group| group["group"].collect(&:buyers_count).max}
    sold.empty? ? 0 : sold.sum / sold.size
  end
  
  def avg_deal
    DealSnapshot.only(:deal_id).where({:site_id => self.id}).group.collect{|group| group["group"].collect(&:buyers_count).max}.sum    
  end                                                                                                                             
  
  def closed_today
    snaps = DealSnapshot.by_date_range(Time.now - 1.days, Time.now, {:site_id => self.id}).collect(&:deal_id).uniq
    Deal.where(:id => snaps, :active => 0).count
  end                               
  
  def closed_yesterday
    snaps = DealSnapshot.by_date_range(Time.now - 2.days, Time.now - 1.days, {:site_id => self.id}).collect(&:deal_id).uniq
    Deal.where(:id => snaps, :active => 0).count
  end

  def closed_week
    snaps = DealSnapshot.by_date_range(Time.now - 7.days, Time.now, {:site_id => self.id}).collect(&:deal_id).uniq
    Deal.where(:id => snaps, :active => 0).count
  end                                                             
  
  def purchased_today
    DealSnapshot.by_date_range(Time.now - 1.days, Time.now, {:site_id => self.id}).collect(&:last_buyers_count).sum
  end

  def purchased_yesterday
    DealSnapshot.by_date_range(Time.now - 2.days, Time.now - 1.days, {:site_id => self.id}).collect(&:last_buyers_count).sum
  end

  def purchased_week
    DealSnapshot.by_date_range(Time.now - 7.days, Time.now, {:site_id => self.id}).collect(&:last_buyers_count).sum
  end                                           
  
  def revenue_today
    deals = {}                                                                                                                
    Deal.where(:site_id => self.id).each {|d| deals[d.id] = d.sale_price}
    DealSnapshot.only(:deal_id).by_date_range(Time.now - 1.days, Time.now, {:site_id => self.id}).group.collect{|group| deals[group["deal_id"].to_i] * group["group"].max(&:buyers_count).buyers_count }.sum    
  end

  def revenue_yesterday
    deals = {}                                                                                                                
    Deal.where(:site_id => self.id).each {|d| deals[d.id] = d.sale_price}
    DealSnapshot.only(:deal_id).by_date_range(Time.now - 2.days, Time.now-1.days, {:site_id => self.id}).group.collect{|group| deals[group["deal_id"].to_i] * group["group"].max(&:buyers_count).buyers_count }.sum    
  end

  def revenue_week
    deals = {}                                                                                                                
    Deal.where(:site_id => self.id).each {|d| deals[d.id] = d.sale_price}
    DealSnapshot.only(:deal_id).by_date_range(Time.now - 7.days, Time.now, {:site_id => self.id}).group.collect{|group| deals[group["deal_id"].to_i] * group["group"].max(&:buyers_count).buyers_count }.sum    
  end            
  
  def avg_revenue_today
    deals = {}                                                                                                                
    Deal.where(:site_id => self.id).each {|d| deals[d.id] = d.sale_price}
    revenue = DealSnapshot.only(:deal_id).by_date_range(Time.now - 1.days, Time.now, {:site_id => self.id}).group.collect{|group| deals[group["deal_id"].to_i] * group["group"].max(&:buyers_count).buyers_count }
    revenue.empty? ? 0 : revenue.sum / revenue.size
  end
  
  def avg_revenue_yesterday
    deals = {}                                                                                                                
    Deal.where(:site_id => self.id).each {|d| deals[d.id] = d.sale_price}
    revenue = DealSnapshot.only(:deal_id).by_date_range(Time.now - 2.days, Time.now - 1.days, {:site_id => self.id}).group.collect{|group| deals[group["deal_id"].to_i] * group["group"].max(&:buyers_count).buyers_count }
    revenue.empty? ? 0 : revenue.sum / revenue.size
  end
  

  def currently_trending
    Site.find_by_sql(["SELECT deals.name, deals.permalink, divisions.name as division, deals.hotness FROM deals, divisions WHERE deals.division_id = divisions.id AND deals.site_id = ? ORDER BY hotness DESC LIMIT 10", self.id])
  end
  
  def get_info
    data = SiteInfo.find(:first, :conditions => {:site_id => self.id})
  end

  def self.coupons_purchased_to_date
    # find_by_sql("select SUM(c) as purchased from (SELECT deal_id, MAX(sold_count) AS c FROM snapshots GROUP BY deal_id order by deal_id desc) x").first.purchased.to_i
    DealSnapshot.only(:deal_id).group.collect{|group| group["group"].collect(&:buyers_count).max}.sum
  end
end
