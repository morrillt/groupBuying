class ChartJob
   @queue = :chart

  def self.perform(site_id = nil)
    Mongoid.database.connection.reconnect # Clean all tmp.map_reduce collections
    unless site_id
      puts "Start ChartJob[#{Time.now}]"
      hourly_revenue_by_site        
      Site.active.each do |site|
        Resque.enqueue(ChartJob, site.id)
      end      
      puts "ChartJob Finish"            
    else
      puts "ChartJob Start for #{site_id}"
      begin      
        site = Site.find(site_id)
        hourly_revenue_by_divisions(site.id)
        get_site_info(site.id)
      rescue => e
        puts "Error:"
        puts "-"*90
        puts e.message
      end
      puts "ChartJob for #{site_id} - Finish"
    end
    Mongoid.database.connection.reconnect # Clean all tmp.map_reduce collections
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
        data[division_id] ||= {:data => {}}
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
    data.tracked_active = Deal.active.by_site(site_id).length

    # deals tracked to date
    data.deals_tracked = Deal.by_site(site_id).length

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
    data.avg_price_per_deal = site.avg_price_per_deal

    #avg revenue per deal
    # data.avg_deal = Deal.find_by_sql("select avg(c) as prom from (SELECT MAX(sold_count) * sale_price  AS c FROM snapshots LEFT JOIN deals on snapshots.deal_id=deals.id where deals.site_id = #{site_id} GROUP BY snapshots.deal_id ) x;").first.prom.to_f
    data.avg_revenue_per_deal = site.avg_revenue_per_deal
    
    data.deals_closed      = site.deals_closed_by_periods
    data.coupons_purchased = site.coupons_purchased_by_periods 
    data.revenue_by_periods= site.revenue_by_periods
    data.average_revenue   = site.average_revenue_by_periods
    
    data.save    
    return data     
  end   
end