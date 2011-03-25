class ChartJob
   @queue = :chart

  def self.perform(site_id = nil)   
    puts "ChartJob Run"        
    hourly_revenue_by_site  
    Site.active.each do |site|
      hourly_revenue_by_divisions(site.id)
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
end