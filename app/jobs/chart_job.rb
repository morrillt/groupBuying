class ChartJob
   @queue = :chart

  def self.perform(site_id = nil)   
    puts "ChartJob Run"        
    hourly_revenue_by_site  
    Site.active.each do |site|
      hourly_revenue_by_divisions(site.id)
      get_site_info(site.id)
    end
    puts "ChartJob Finish"            
  end
  
  def self.hourly_revenue_by_site
    today= Time.now
    
    data = {}
    sites = Site.active
    
    sites.each { |s|
      data[s.id.to_s] = {}
    }
    
    sites.each do |site|     
      (1..24).map do |t|
        today= Time.now-t.hours
        revenue = site.revenue_by_given_hour_and_date(today.hour, today)
        data[site.id.to_s][t.to_s] = revenue
      end      
    end                     
        
    sites.each do |s|
      hr = HourlyRevenueBySite.find_or_create_by(:site_id => s.id)
      hr.revenue = data[s.id.to_s]
      hr.save
    end    
  end
  
  def self.hourly_revenue_by_divisions(site_id)
    return unless site_id   
    site= Site.active.find(site_id)
    divisions = site.divisions.order('name ASC')
    today= Time.now
    
    data = {}
    divisions.each {|div|
      data[div.id.to_s] = {:site_id => div.site_id, :data => {}}
    }                 
    
    (1..24).map do |t|
      today= Time.now - t.hours # should not be Time.now
      revenues = site.revenue_for_all_divisions_by_given_hour_and_date(today.hour, today)            
      revenues.each do |r|
        data[r.id][:data][t.to_s] = r.rev.to_f
      end
    end                                               
    placeholder = {}
    (1..24).each {|i| placeholder[i.to_s] = 0}
    
    data.keys.each {|div_id|
      hr = HourlyRevenueByDivision.find_or_create_by(:division_id => div_id, :site_id => data[div_id][:site_id] )
      hr.revenue = data[div_id.to_s][:data].empty? ? placeholder : data[div_id.to_s][:data]
      hr.save
    }
  end  
  
  #Yep, I know this is not the most beatiful thing... 
  def self.get_site_info(site_id) 
    data = SiteInfo.find_or_create_by(:site_id => site_id) 
    #active deals
    data.tracked_active = Deal.find(:all, :conditions => {:site_id =>  site_id, :active => true }).length

    # deals tracked to date
    data.deals_tracked = Deal.find(:all,:conditions => {:site_id => site_id}).length

    #coupones purchased to date
    data.coupon_purchased = Deal.find_by_sql("select sum(c) as purchased from (SELECT deal_id, MAX(sold_count) AS c FROM snapshots where site_id = #{site_id} GROUP BY deal_id order by deal_id desc) x;").first.purchased.to_i

    #total revenue to date
    data.total_revenue = Deal.find_by_sql("select sum(c) as rev from(SELECT MAX(sold_count) * sale_price  AS c, snapshots.site_id FROM snapshots LEFT JOIN deals on snapshots.deal_id=deals.id where deals.site_id = #{site_id} GROUP BY snapshots.deal_id ) x;").first.rev.to_i

    #average coupon sold per deal
    data.avg_coupon = Deal.find_by_sql("select avg(sold) as coupon_sold from (select distinct(snapshots.deal_id),max(sold_count) as sold from snapshots left join deals on deals.id = snapshots.deal_id where deals.site_id = #{site_id}) x;").first.coupon_sold.to_f

    #average price per deal
    data.price_deal = Deal.find_by_sql("select avg(sale_price) as price from deals where site_id = #{site_id};").first.price.to_f

    #avg revenue per deal
    data.avg_deal = Deal.find_by_sql("select avg(c) as prom from (SELECT MAX(sold_count) * sale_price  AS c FROM snapshots LEFT JOIN deals on snapshots.deal_id=deals.id where deals.site_id = #{site_id} GROUP BY snapshots.deal_id ) x;").first.prom.to_f

    # deal closed today
    data.closed_today = Deal.find_by_sql("SELECT COUNT(DISTINCT(deals.id)) as closed FROM snapshots LEFT JOIN deals on snapshots.deal_id=deals.id WHERE active=0 and deals.id = #{site_id} AND DATE(snapshots.created_at)>=DATE_SUB(DATE(NOW()), INTERVAL 8 DAY) AND DATE(snapshots.created_at)<=DATE(NOW())").first.closed

    #deals closed yesterday
    data.closed_yesterday = Deal.find_by_sql("SELECT COUNT(DISTINCT(deal_id)) as closed FROM snapshots WHERE status=0 AND
    DATE(created_at)=DATE_SUB(DATE(NOW()), INTERVAL 1 DAY) and site_id = #{site_id}").first.closed

    #deals closed this week
    data.closed_week = Deal.find_by_sql("SELECT COUNT(DISTINCT(deals.id)) as closed FROM snapshots LEFT JOIN deals on snapshots.deal_id=deals.id WHERE active=0 and deals.site_id = #{site_id} AND DATE(snapshots.created_at)>=DATE_SUB(DATE(NOW()), INTERVAL 8 DAY) AND DATE(snapshots.created_at)<=DATE(NOW());").first.closed

    #coupons purchased today
    data.purchased_today = Deal.find_by_sql("select sum(sold_since_last_snapshot_count) as nsold from snapshots where
    DATE(created_at)=DATE(NOW()) and site_id = #{site_id}").first.nsold.to_i

    #coupons purchased yesterday
    data.purchased_yesterday = Deal.find_by_sql("select sum(sold_since_last_snapshot_count) as nsold from snapshots where DATE(created_at)=DATE_SUB(DATE(NOW()), INTERVAL 1 DAY) and site_id = #{site_id}").first.nsold.to_i

    #coupons purchased week
    data.purchased_week = Deal.find_by_sql("select sum(sold_since_last_snapshot_count) as nsold from snapshots where DATE(created_at)>=DATE_SUB(DATE(NOW()), INTERVAL 8 DAY) and DATE(created_at)<=DATE(NOW()) and site_id = #{site_id}").first.nsold.to_i

    #revenue today
    data.revenue_today = Deal.find_by_sql("select sum(c) as prom from (SELECT MAX(sold_count) * sale_price  AS c FROM snapshots LEFT JOIN deals on snapshots.deal_id=deals.id WHERE deals.site_id = #{site_id} and DATE(snapshots.created_at) = DATE(NOW()) GROUP BY snapshots.deal_id ) x;").first.prom.to_i

    #revenue yesterday
    data.revenue_yesterday = Deal.find_by_sql("select sum(c) as revt from (SELECT MAX(sold_count) * sale_price  AS c FROM snapshots LEFT JOIN deals on snapshots.deal_id=deals.id WHERE deals.site_id = #{site_id} and DATE(snapshots.created_at) = DATE_SUB(DATE(NOW()), INTERVAL 1 DAY) GROUP BY snapshots.deal_id ) x;").first.revt.to_i

    #avg revenue today
    data.avg_revenue_today = Deal.find_by_sql("select avg(c) as avg_revenue_today from (SELECT MAX(sold_count) * sale_price  AS c FROM snapshots LEFT JOIN deals on snapshots.deal_id=deals.id WHERE deals.site_id = 1 and DATE(snapshots.created_at)=date(now()) GROUP BY snapshots.deal_id ) x;").first.avg_revenue_today.to_f

    #avg revenue yesterday
    data.avg_revenue_yesterday = Deal.find_by_sql("select avg(c) as avg_rev from (SELECT MAX(sold_count) * sale_price  AS c FROM snapshots LEFT JOIN deals on snapshots.deal_id=deals.id WHERE deals.site_id = 1 and DATE(snapshots.created_at)=DATE_SUB(DATE(NOW()), INTERVAL 1 DAY) GROUP BY snapshots.deal_id ) x;").first.avg_rev.to_i

    ###changes in %
    # coupons closed today-yesterday    
    unless data.closed_yesterday==0
      data.change_today_yesterday = (data.closed_today - data.closed_yesterday)/data.closed_yesterday
    else
      data.change_today_yesterday = "No data"
    end

    # coupons closed today-yesterday
    tmp = Deal.find_by_sql("SELECT COUNT(DISTINCT(deal_id)) as closed FROM snapshots WHERE status=0 and DATE(created_at)>=DATE_SUB(DATE(NOW()), INTERVAL 2 DAY) and DATE(created_at)<=DATE_SUB(DATE(NOW()), INTERVAL 1 DAY) and site_id = #{site_id}").first.closed

    unless tmp==0
      data.change_yesterday = (data.closed_yesterday - tmp )/tmp
    else
      data.change_yesterday = "No data"
    end

    # coupons change today-yesterday
    unless data.purchased_today==0
      data.purchased_change_today = if(data.purchased_yesterday == 0) 
        data.purchased_today
      else
        (data.purchased_today.to_i - data.purchased_yesterday.to_i) / data.purchased_yesterday
      end
    else
      data.purchased_change_today = "No data"
    end

    # coupons change yesterday-
    tmp = Deal.find_by_sql("select sum(sold_since_last_snapshot_count) as nsold from snapshots where DATE(created_at)>=DATE_SUB(DATE(NOW()), INTERVAL 2 DAY) and DATE(created_at)<=DATE_SUB(DATE(NOW()), INTERVAL 1 DAY) and site_id = #{site_id}").first.nsold.to_i

    unless tmp==0
      data.change_purchased_yesterday = (data.purchased_yesterday - tmp )/tmp
    else
      data.change_purchased_yesterday = "No data"
    end      
    
    data.save

    return data
  end   
end