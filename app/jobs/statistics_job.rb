class StatisticsJob
   @queue = :statistics

  def self.perform(site_id = nil)
    Mongoid.database.connection.reconnect # Clean all tmp.map_reduce collections
    unless site_id
      puts "Start StatisticsJob[#{Time.now}]"
      Site.active.each do |site|
        Resque.enqueue(StatisticsJob, site.id)
      end      
      puts "StatisticsJob Finish"            
    else
      puts "StatisticsJob Start for #{site_id}"
      begin      
        site = Site.find(site_id)
        get_site_info(site.id)
      rescue => e
        puts "Error:"
        puts "-"*90
        puts e.message
        puts e.backtrace.join("\n")
      end
      puts "StatisticsJob for #{site_id} - Finish"
    end
    Mongoid.database.connection.reconnect # Clean all tmp.map_reduce collections
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