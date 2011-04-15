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
      rescue => e
        puts "Error:"
        puts "-"*90
        puts e.message
        puts e.backtrace.join("\n")
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
end