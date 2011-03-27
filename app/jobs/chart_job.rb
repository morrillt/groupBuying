class ChartJob
   @queue = :chart

  def self.perform
    puts "ChartJob Start"
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
      (0..23).map do |t|
        today = (Time.now - t.hours)
        revenue = site.revenue_by_given_hour_and_date(today.hour, today)
        data[site.id.to_s]["%02d"%t] = revenue   # second parameter eql("preceding 1-9 with zero")
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
      data[div.id] = {:site_id => div.site_id, :data => {}}
    }
    
    # only build this once
    hours_array = (0..23).to_a   

    hours_array.map do |t|
      today = (Time.now - t.hours)
      revenues = site.revenue_for_all_divisions_by_given_hour_and_date(today.hour, today)            
      revenues.each do |division_id, revenue|
        data[division_id][:data]["%02d"%t] = revenue.to_f  # second parameter eql("preceding 1-9 with zero")
      end
    end   
                                                            
    placeholder = {}
    hours_array.each {|i| placeholder["%02d"%i] = 0}
    
    data.keys.each {|div_id|
      hr = HourlyRevenueByDivision.find_or_create_by(:division_id => div_id, :site_id => data[div_id][:site_id] )
      hr.revenue = data[div_id][:data].empty? ? placeholder : data[div_id][:data]
      hr.save
    }
  end  
  
  #Yep, I know this is not the most beatiful thing... 
  def self.get_site_info(site_id)                            
    site = Site.active.find(site_id)
    data = SiteInfo.find_or_create_by(:site_id => site_id)    
    
    #active deals
    data.tracked_active = Deal.find(:all, :conditions => {:site_id =>  site_id, :active => true }).length

    # deals tracked to date
    data.deals_tracked = Deal.find(:all,:conditions => {:site_id => site_id}).length

    #coupones purchased to date
    # data.coupon_purchased = Deal.find_by_sql("select sum(c) as purchased from (SELECT deal_id, MAX(sold_count) AS c FROM snapshots where site_id = #{site_id} GROUP BY deal_id order by deal_id desc) x;").first.purchased.to_i
    data.coupon_purchased = site.coupon_purchased
    
    #total revenue to date
    # data.total_revenue = Deal.find_by_sql("select sum(c) as rev from(SELECT MAX(sold_count) * sale_price  AS c, snapshots.site_id FROM snapshots LEFT JOIN deals on snapshots.deal_id=deals.id where deals.site_id = #{site_id} GROUP BY snapshots.deal_id ) x;").first.rev.to_i
    data.total_revenue = site.total_revenue
    
    #average coupon sold per deal
    # data.avg_coupon = Deal.find_by_sql("select avg(sold) as coupon_sold from (select distinct(snapshots.deal_id),max(sold_count) as sold from snapshots left join deals on deals.id = snapshots.deal_id where deals.site_id = #{site_id}) x;").first.coupon_sold.to_f
    data.avg_coupon = site.avg_coupon
    
    # #average price per deal
    data.price_deal = Deal.find_by_sql("select avg(sale_price) as price from deals where site_id = #{site_id};").first.price.to_f

    #avg revenue per deal
    # data.avg_deal = Deal.find_by_sql("select avg(c) as prom from (SELECT MAX(sold_count) * sale_price  AS c FROM snapshots LEFT JOIN deals on snapshots.deal_id=deals.id where deals.site_id = #{site_id} GROUP BY snapshots.deal_id ) x;").first.prom.to_f
    data.avg_deal = site.avg_deal

    # deal closed today
    # data.closed_today = Deal.find_by_sql("SELECT COUNT(DISTINCT(deals.id)) as closed FROM snapshots LEFT JOIN deals on snapshots.deal_id=deals.id WHERE active=0 and deals.id = #{site_id} AND DATE(snapshots.created_at)>=DATE_SUB(DATE(NOW()), INTERVAL 8 DAY) AND DATE(snapshots.created_at)<=DATE(NOW())").first.closed
    data.closed_today = site.closed_today

    #deals closed yesterday
    # data.closed_yesterday = Deal.find_by_sql("SELECT COUNT(DISTINCT(deal_id)) as closed FROM snapshots WHERE status=0 AND DATE(created_at)=DATE_SUB(DATE(NOW()), INTERVAL 1 DAY) and site_id = #{site_id}").first.closed
    data.closed_yesterday = site.closed_yesterday
    
    #deals closed this week
    # data.closed_week = Deal.find_by_sql("SELECT COUNT(DISTINCT(deals.id)) as closed FROM snapshots LEFT JOIN deals on snapshots.deal_id=deals.id WHERE active=0 and deals.site_id = #{site_id} AND DATE(snapshots.created_at)>=DATE_SUB(DATE(NOW()), INTERVAL 8 DAY) AND DATE(snapshots.created_at)<=DATE(NOW());").first.closed
    data.closed_week = site.closed_week

    #coupons purchased today
    # data.purchased_today = Deal.find_by_sql("select sum(sold_since_last_snapshot_count) as nsold from snapshots where DATE(created_at)=DATE(NOW()) and site_id = #{site_id}").first.nsold.to_i
    data.purchased_today = site.purchased_today

    #coupons purchased yesterday
    # data.purchased_yesterday = Deal.find_by_sql("select sum(sold_since_last_snapshot_count) as nsold from snapshots where DATE(created_at)=DATE_SUB(DATE(NOW()), INTERVAL 1 DAY) and site_id = #{site_id}").first.nsold.to_i
    data.purchased_yesterday = site.purchased_yesterday
    
    #coupons purchased week
    # data.purchased_week = Deal.find_by_sql("select sum(sold_since_last_snapshot_count) as nsold from snapshots where DATE(created_at)>=DATE_SUB(DATE(NOW()), INTERVAL 8 DAY) and DATE(created_at)<=DATE(NOW()) and site_id = #{site_id}").first.nsold.to_i
    data.purchased_week = site.purchased_week    

    #revenue today
    # data.revenue_today = Deal.find_by_sql("select sum(c) as prom from (SELECT MAX(sold_count) * sale_price  AS c FROM snapshots LEFT JOIN deals on snapshots.deal_id=deals.id WHERE deals.site_id = #{site_id} and DATE(snapshots.created_at) = DATE(NOW()) GROUP BY snapshots.deal_id ) x;").first.prom.to_i
    data.revenue_today = site.revenue_today

    # #revenue yesterday
    # data.revenue_yesterday = Deal.find_by_sql("select sum(c) as revt from (SELECT MAX(sold_count) * sale_price  AS c FROM snapshots LEFT JOIN deals on snapshots.deal_id=deals.id WHERE deals.site_id = #{site_id} and DATE(snapshots.created_at) = DATE_SUB(DATE(NOW()), INTERVAL 1 DAY) GROUP BY snapshots.deal_id ) x;").first.revt.to_i
    data.revenue_yesterday = site.revenue_yesterday
    
    # #avg revenue today
    # data.avg_revenue_today = Deal.find_by_sql("select avg(c) as avg_revenue_today from (SELECT MAX(sold_count) * sale_price  AS c FROM snapshots LEFT JOIN deals on snapshots.deal_id=deals.id WHERE deals.site_id = 1 and DATE(snapshots.created_at)=date(now()) GROUP BY snapshots.deal_id ) x;").first.avg_revenue_today.to_f
    data.avg_revenue_today = site.avg_revenue_today
    
    # #avg revenue yesterday
    # data.avg_revenue_yesterday = Deal.find_by_sql("select avg(c) as avg_rev from (SELECT MAX(sold_count) * sale_price  AS c FROM snapshots LEFT JOIN deals on snapshots.deal_id=deals.id WHERE deals.site_id = 1 and DATE(snapshots.created_at)=DATE_SUB(DATE(NOW()), INTERVAL 1 DAY) GROUP BY snapshots.deal_id ) x;").first.avg_rev.to_i
    data.avg_revenue_yesterday = site.avg_revenue_yesterday
    
    # ###changes in %
    # coupons closed today-yesterday    
    unless data.closed_yesterday == 0
      data.change_today_yesterday = (data.closed_today - data.closed_yesterday) / data.closed_yesterday
    else
      data.change_today_yesterday = "No data"
    end

    # coupons closed today-yesterday
    # tmp = Deal.find_by_sql("SELECT COUNT(DISTINCT(deal_id)) as closed FROM snapshots WHERE status=0 and DATE(created_at)>=DATE_SUB(DATE(NOW()), INTERVAL 2 DAY) and DATE(created_at)<=DATE_SUB(DATE(NOW()), INTERVAL 1 DAY) and site_id = #{site_id}").first.closed
    snaps = DealSnapshot.by_date_range(1.days.ago.at_midnight, 0.days.ago.at_midnight, {:site_id => self.id}).collect(&:deal_id).uniq
    tmp = Deal.where(:id => snaps, :active => 0).count
       
    unless tmp == 0
      data.change_yesterday = (data.closed_yesterday - tmp ) / tmp
    else
      data.change_yesterday = "No data"
    end
    
    # coupons change today-yesterday
    unless data.purchased_today == 0
      data.purchased_change_today = if(data.purchased_yesterday == 0) 
        data.purchased_today
      else
        (data.purchased_today.to_i - data.purchased_yesterday.to_i) / data.purchased_yesterday
      end
    else
      data.purchased_change_today = "No data"
    end
    
    # # coupons change yesterday-
    # tmp = Deal.find_by_sql("select sum(sold_since_last_snapshot_count) as nsold from snapshots where DATE(created_at)>=DATE_SUB(DATE(NOW()), INTERVAL 2 DAY) and DATE(created_at)<=DATE_SUB(DATE(NOW()), INTERVAL 1 DAY) and site_id = #{site_id}").first.nsold.to_i
    tmp = DealSnapshot.by_date_range(1.days.ago.at_midnight, 0.days.ago.at_midnight, {:site_id => self.id}).collect(&:last_buyers_count).sum
    
    unless tmp==0
      data.change_purchased_yesterday = (data.purchased_yesterday - tmp )/tmp
    else
      data.change_purchased_yesterday = "No data"
    end      
    
    data.save
    
    return data     
  end   
end