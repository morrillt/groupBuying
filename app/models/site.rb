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
  # =================================== Or not? ========================================
  
  def coupon_purchased
    Deal.by_site(self.id).sum(:max_sold_count)
  end   
                      
  def total_revenue                     
    Deal.by_site(self.id).select("max_sold_count * sale_price as rev").collect(&:rev).sum.to_i
  end 
  
  def avg_coupon
    coupon_purchased == 0 ? 0 : total_revenue / coupon_purchased
  end
  
  def avg_deal
    deals = Deal.by_site(self.id).collect(&:max_sold_count)
    deals.empty? ? 0 : deals.sum / deals.size 
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
    deal_ids = DealSnapshot.by_date_range(Time.now - 1.days, Time.now, {:site_id => self.id}).collect(&:deal_id).uniq
    Deal.where(:deal_id => deal_ids).collect{|deal| deal.max_sold_count * deal.sale_price}.sum
  end

  def revenue_yesterday
    deal_ids = DealSnapshot.by_date_range(Time.now - 2.days, Time.now - 1.days, {:site_id => self.id}).collect(&:deal_id).uniq
    Deal.where(:deal_id => deal_ids).collect{|deal| deal.max_sold_count * deal.sale_price}.sum
  end

  def revenue_week
    deal_ids = DealSnapshot.by_date_range(Time.now - 7.days, Time.now, {:site_id => self.id}).collect(&:deal_id).uniq
    Deal.where(:deal_id => deal_ids).collect{|deal| deal.max_sold_count * deal.sale_price}.sum
  end            
  
  def avg_revenue_today
    purchased_today == 0 ? 0 : revenue_today / purchased_today
  end
  
  def avg_revenue_yesterday
    purchased_yesterday == 0 ? 0 : revenue_yesterday / purchased_yesterday
  end  

  def currently_trending
    Site.find_by_sql(["SELECT deals.name, deals.permalink, divisions.name as division, deals.hotness FROM deals, divisions WHERE deals.division_id = divisions.id AND deals.site_id = ? ORDER BY hotness DESC LIMIT 10", self.id])
  end
  
  def get_info
    data = SiteInfo.find(:first, :conditions => {:site_id => self.id})
  end

  def self.coupons_purchased_to_date
    # find_by_sql("select SUM(c) as purchased from (SELECT deal_id, MAX(sold_count) AS c FROM snapshots GROUP BY deal_id order by deal_id desc) x").first.purchased.to_i
    # DealSnapshot.only(:deal_id).group.collect{|group| group["group"].collect(&:buyers_count).max}.sum
    Deal.sum(:max_sold_count)
  end
end
