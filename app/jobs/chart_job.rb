class ChartJob
   @queue = :chart

  def self.perform(site_id = nil)   
    puts "ChartJob Run"        
    hourly_revenue_by_site
    puts "ChartJob Finish"            
  end
  
  def self.hourly_revenue_by_site
    today= Time.now
    
    Site.active.each do |site|     
      data= (1..24).map do |t|
        today= Time.now-t.hours
        revenue = site.revenue_by_given_hour_and_date(today.hour, today)
        hr = HourlyRevenueBySite.find_or_create_by_site_id_and_order(site.id, t)
        hr.revenue = revenue
        hr.save
      end      
    end
  end
  
   
end