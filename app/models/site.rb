class Site < ActiveRecord::Base
  
  STATS_PERIODS = [1, 7, 30, 90]
  
  has_many :snapshots, :dependent => :destroy
  has_many :deals#, :through => :divisions
  has_many :divisions, :dependent => :destroy
  has_many :hourly_revenue_by_site

  scope :active, where(:active => true)
  # scope :inactive, where(:active => false)
  
  # Updates all the sites active deals buy createing
  # snapshots of the deal
  def update_snapshots!(range = nil, snapshot_job = nil)
    if snapshooter.strategy == :crawler
      deals_to_snapshot = deals.active 
      deals_to_snapshot = deals_to_snapshot.limit(range[1] - range[0]).offset(range[0]) if range

      total = deals_to_snapshot.length
      num = 0        
      
      deals_to_snapshot.each do |deal|
        snapshot_job.report_status(num, total) if snapshot_job
        deal.take_mongo_snapshot!
        num +=1 
      end
      
    elsif snapshooter.strategy == :api
      snapshooter.update_snapshots!(range, snapshot_job) # Delegate to snapshooter class
    end
  end
  
  # Captures new deals in the database
  def crawl_new_deals!(range = nil, crawler_job = nil)
    begin                                      
      snapshooter.crawler_job = crawler_job
      snapshooter.crawl_new_deals!(range)
    rescue => e
      puts "Error: #{e}"
      puts "-"*90
    end
  end                 
  
  # Divide work by divisions 
  #   params:
  #     <tt>job_class</tt> - job class to enqueue
  #     <tt>count</tt> - overall of elements
  def enqueue_by_divisions(job_class, options={})
    options[:count] ||= divisions.count
    snapshooter.enqueue_by_divisions(job_class, options)
  end
                                                 
  # Divide work by deals
  #   params:
  #     <tt>job_class</tt> - job class to enqueue
  #     <tt>count</tt> - range of elements
  def enqueue_by_deals(job_class, options = {})
    options[:count] ||= deals.count
    snapshooter.enqueue_by_deals(job_class, options)
  end
                                    
  # Trying to capture more deals with bruteforce
  def crawl_old_deals_with_bruteforce          
    snapshooter.crawl_old_deals_with_bruteforce
  end
                          
  # Updates max_sold_count for expired deals
  def update_expired_deals
    deals.inactive.each do |deal|
      deal.update_attribute(:max_sold_count, deal.capture_sold_count)
    end
  end

  # Updates deals info
  #   params:
  #     <tt>options</tt>: {:range => } - range of elements
  #                       {:active => 1} - update active deals only?
  #                       {:attributes => 'max_sold_count expires_at'} - which attributes to update
  def crawl_and_update_deals_info(options = {}, update_deals_job = nil)
    range = options.delete(:range) || options.delete("range")
    active = options.delete(:active) || options.delete("active")
    attributes = options.delete(:attributes) || options.delete("attributes")

    update_deals = deals

    update_deals.where(options) unless options.empty?
    update_deals.active if active && active == 1

    update_deals.limit(range[1] - range[0]).offset(range[0]) if range
    total = update_deals.length
    num = 0
    update_deals.each{ |deal|
      deal.update_info(attributes)
      update_deals_job.report_status(num, total) if update_deals_job
      num += 1
    }
  end
  
  # Returns a mongoid collection of DealSnapshot belonging
  # to this site
  def snapshots
    @snapshots ||= DealSnapshot.where(:site_id => self.id)
  end
  
  # Returns a String
  # Returns the last snapshot timestamp as a 
  # String for the current site instance
  def last_snapshot_at(time_format = "%m/%d/%Y %I:%M:%S %p")
    return @last_snapshot unless @last_snapshot.nil?
    if @last_snapshot = snapshots.order(:created_at.desc).limit(1)[0]
      return @last_snapshot.created_at.strftime(time_format)
    else
      return "None Available"
    end
  end
  
  # Returns a String
  # Returns the last deal timestamp as a 
  # String for the current site instance
  def last_deal_at(time_format = "%m/%d/%Y %I:%M:%S %p")
    if deals.empty?
      return "None Available"
    else
      return @last_deal_at ||= deals.last.created_at.strftime(time_format)
    end
  end
  
  # Returns a new instance of the Site Snapshooter class
  # Example:
  #  Snapshooter::KgbDeals.new
  def snapshooter
    @snapshooter ||= snapshooter_class.new(self.source_name)
  end

  def snapshooter_class
    case self.source_name
    when 'kgb_deals'
      Snapshooter::KgbDeals
    when 'travel_zoo', 'travel_zoo_uk'
      Snapshooter::TravelZoo
    when 'homerun'
      Snapshooter::Homerun
    when 'open_table'
      Snapshooter::OpenTable
    when 'groupon'
      Snapshooter::GrouponApi
    when 'living_social'
      Snapshooter::LivingSocial
    when 'ideal_golfer'
      Snapshooter::IdealGolfer
    when 'weforia'
      Snapshooter::Weforia
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
    # puts "revenue_by_given_hour_and_date(#{hour},#{date})"
    #snapshots= Snapshot.find_by_sql ["SELECT snapshots.deal_id, SUM(sold_since_last_snapshot_count) AS total_count, deals.sale_price FROM snapshots, deals WHERE snapshots.site_id = ? AND YEAR(snapshots.created_at) = ? AND MONTH(snapshots.created_at) = ? AND DAY(snapshots.created_at) = ? AND HOUR(snapshots.created_at) = ? AND sold_since_last_snapshot_count NOT IN (0) AND snapshots.deal_id = deals.id GROUP BY deal_id", self.id, date.year, date.month, date.day, hour]
    start_at = Time.parse("#{date.year}-#{date.month}-#{date.day} #{hour}:00:00").utc
    end_at   = Time.parse("#{date.year}-#{date.month}-#{date.day} #{hour}:59:59").utc
    snapshots = DealSnapshot.by_date_range(start_at, end_at, :site_id => self.id)
    # puts "Snapshots: #{snapshots.count}"

    # Get snapshots deals and buyers count
    buyers= {}
    snapshots.each do |s|
      buyers[s.deal_id] ||= 0 
      buyers[s.deal_id] += s.buyers_count - s.last_buyers_count
    end                                   
    
    # Get Deals prices
    snapshot_deals = {}
    Deal.select("id, sale_price").find_all_by_id(buyers.keys).map {|deal|
      snapshot_deals[deal.id] = deal.sale_price
    }                 
    
    revenue = snapshot_deals.collect {|k, v|
      v * buyers[k]
    }.sum        
    
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
      revenues[s.division_id] += ((s.buyers_count - s.last_buyers_count) * s.price.to_f)
    end
    revenues
  end  
  
  def total_revenue_from_deals
    deals.collect{|deal| deal.max_sold_count * deal.sale_price}.sum
  end    
   
  # ================================== Statistics ======================================
  
  def coupon_purchased
    Deal.by_site(self.id).sum(:max_sold_count)
  end   
                      
  def total_revenue                     
    Deal.by_site(self.id).select("SUM(max_sold_count * sale_price) as rev").first.rev.to_i
  end 
  
  def avg_coupon
    coupon_purchased == 0 ? 0 : coupon_purchased / Deal.by_site(self.id).count
  end    
  
  def avg_price_per_deal
    Deal.by_site(self.id).average('sale_price').to_f
  end
  
  def avg_revenue_per_deal                                                
    avg_coupon * avg_price_per_deal
  end                                                                                                                             
  
  def closed_today
    ids = DealSnapshot.by_date_range(0.days.ago.at_midnight, Time.now, {:site_id => self.id}).collect(&:deal_id).uniq
    deals_count_by_deals_ids(ids)
  end                               
  
  def closed_yesterday
    ids = DealSnapshot.by_date_range(1.days.ago.at_midnight, 0.days.ago.at_midnight, {:site_id => self.id}).collect(&:deal_id).uniq
    Deal.where(:id => ids, :active => 0).count
  end

  def closed_week
    ids = DealSnapshot.by_date_range(7.days.ago.at_midnight, Time.now, {:site_id => self.id}).collect(&:deal_id).uniq
    Deal.where(:id => ids, :active => 0).count
  end                                                             
  
  def purchased_today
    DealSnapshot.by_date_range(0.days.ago.at_midnight, Time.now, {:site_id => self.id}).sum(:last_buyers_count) || 0
  end

  def purchased_yesterday
    DealSnapshot.by_date_range(1.days.ago.at_midnight, 0.days.ago.at_midnight, {:site_id => self.id}).sum(:last_buyers_count) || 0
  end

  def purchased_week
    DealSnapshot.by_date_range(7.days.ago.at_midnight, Time.now, {:site_id => self.id}).sum(:last_buyers_count) || 0
  end                                           
  
  def revenue_today    
    deal_ids = DealSnapshot.by_date_range(0.days.ago.at_midnight, Time.now, {:site_id => self.id}).collect(&:deal_id).uniq   
    revenue_by_deals_ids(deal_ids)
  end

  def revenue_yesterday
    deal_ids = DealSnapshot.by_date_range(1.days.ago.at_midnight, 0.days.ago.at_midnight, {:site_id => self.id}).collect(&:deal_id).uniq
    revenue_by_deals_ids(deal_ids)
  end

  def revenue_week
    deal_ids = DealSnapshot.by_date_range(7.days.ago.at_midnight, Time.now, {:site_id => self.id}).collect(&:deal_id).uniq
    revenue_by_deals_ids(deal_ids)
  end            
  
  def avg_revenue_today
    purchased_today == 0 ? 0 : revenue_today / purchased_today
  end
  
  def avg_revenue_yesterday
    purchased_yesterday == 0 ? 0 : revenue_yesterday / purchased_yesterday
  end  

  def currently_trending
    Site.find_by_sql(["SELECT deals.name, deals.permalink, divisions.name as division, deals.hotness FROM deals, divisions WHERE deals.division_id = divisions.id AND deals.site_id = ? AND deals.active = 1 ORDER BY hotness DESC LIMIT 10", self.id])
  end
  
  def get_info
    data = SiteInfo.find(:first, :conditions => {:site_id => self.id})
  end

  def self.coupons_purchased_to_date
    # find_by_sql("select SUM(c) as purchased from (SELECT deal_id, MAX(sold_count) AS c FROM snapshots GROUP BY deal_id order by deal_id desc) x").first.purchased.to_i
    Deal.sum(:max_sold_count)
  end    
  
  # ================================== BY Periods ======================================
  
  def deals_closed_by_periods
    deals_closed = {}
    STATS_PERIODS.each {|t|
      deals_closed[t.to_s]      = deals_closed_by_given_period(t.days.ago, Time.now)
      deals_closed["prev_#{t}"] = deals_closed_by_given_period((2*t).days.ago, t.days.ago)
    }    
    deals_closed
  end 
  
  def deals_closed_by_given_period(from, to)     
    ids = DealSnapshot.by_date_range(from, to, {:site_id => self.id}).collect(&:deal_id).uniq
    Deal.where(:active => false).find_all_by_id(ids).count    
  end

  def coupons_purchased_by_periods  
    coupons_purchased = {}
    STATS_PERIODS.each {|t|   
      coupons_purchased[t.to_s]      = coupons_purchased_by_given_period(t.days.ago, Time.now)
      coupons_purchased["prev_#{t}"] = coupons_purchased_by_given_period((2*t).days.ago, t.days.ago)
    }       
    coupons_purchased
  end      
  
  def coupons_purchased_by_given_period(from, to)
    purchases = DealSnapshot.coupons_purchased_by_given_period(from, to, self.id)
    purchases.values.sum
  end

  def revenue_by_periods     
    revenue_by_periods = {}
    STATS_PERIODS.each {|t|   
      revenue_by_periods[t.to_s]      = revenue_by_given_period(t.days.ago, Time.now)
      revenue_by_periods["prev_#{t}"] = revenue_by_given_period((2*t).days.ago, t.days.ago)
    }   
    revenue_by_periods
  end   
  
  def revenue_by_given_period(from, to)
    purchases = DealSnapshot.coupons_purchased_by_given_period(from, to, self.id)
    revenue = Deal.find_all_by_id(purchases.keys).collect { |deal|
      if purchases[deal.id] and purchases[deal.id] > 0
        deal.sale_price * purchases[deal.id]
      else
        0
      end
    }.compact.sum
    revenue
  end

  def average_revenue_by_periods    
    average_revenue = {}
    STATS_PERIODS.each {|t|   
      average_revenue[t.to_s] = average_revenue_by_given_period(t.days.ago, Time.now)
      average_revenue["prev_#{t}"] = average_revenue_by_given_period((2*t).days.ago, t.days.ago)
    }     
    average_revenue
  end                                           
  
  def average_revenue_by_given_period(from, to) 
    purchases = DealSnapshot.coupons_purchased_by_given_period(from, to, self.id)
    deals = purchases.values.sum
    
    revenue = Deal.find_all_by_id(purchases.keys).collect { |deal|
      if purchases[deal.id] and purchases[deal.id] > 0
        deal.sale_price * purchases[deal.id]
      else
        0
      end
    }.compact.sum                  
        
    deals > 0 ? revenue / deals : 0
  end
  
  private 
  
    def revenue_by_deals_ids(deals_ids)
      Deal.where(:deal_id => deals_ids).select("SUM(max_sold_count * sale_price) as rev").first.rev.to_i
    end    
    
    def deals_count_by_deals_ids(deals_ids)
      Deal.where(:id => deals_ids, :active => 0).count
    end
end
