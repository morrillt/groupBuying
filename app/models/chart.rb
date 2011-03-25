class Chart
  # Returns a hash containing the revenue for each
  # hour during the last 24 hours, for each site
  def self.hourly_revenue_by_site
    chart = init_chart
    hourly_revenues = HourlyRevenueBySite.all
    sites = Site.active
    
    hourly_revenues.each do |hr|
      site_name = sites.detect{|s| s.id == hr.site_id}.name
      data = hr.revenue.keys.sort.reverse.collect{|k| hr.revenue[k]} 
      chart[:series] << { :name => site_name, :data => data } 
    end
    chart
  end

  def self.hourly_revenue_by_divisions(site_id)
    chart = self.init_chart
    hourly_revenues = HourlyRevenueByDivision.where(:site_id => site_id)
    ar_divisions = Division.where(:site_id => site_id).order('name ASC')
    ar_divisions.each do |division|        
      hr_division = hourly_revenues.detect{ |hr| hr.division_id == division.id }
      data = hr_division ?  (1..24).to_a.reverse.collect {|key| hr_division.revenue[key.to_s] } : (1..24).collect { 0 }
      chart[:series] << { :name => division.name, :data => data }        
    end
    chart
  end
  
  private   

  def self.init_chart
    today= Time.now
    chart = {
      :categories => (1..24).map { |t| "#{(today-t.hours).hour}:00" }.reverse,
      :series => []
    }       
    chart
  end
end
