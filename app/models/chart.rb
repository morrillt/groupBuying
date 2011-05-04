class Chart
  # Returns a hash containing the revenue for each
  # hour during the last 24 hours, for each site
  def self.hourly_revenue_by_site
    chart = init_chart
    hourly_revenues = HourlyRevenueBySite.all
    sites = Site.active
    
    hourly_revenues.each do |hr|                       
      site = sites.detect{|s| s.id == hr.site_id}
      if site 
        site_name = site.name
        data = (0..23).to_a.reverse.collect{|k| hr.revenue["%02d"%k]} 
        chart[:series] << { :name => site_name, :data => data } 
      end
    end
    chart
  end

  def self.hourly_revenue_by_divisions(site_id)
    chart = self.init_chart
    hourly_revenues = HourlyRevenueByDivision.where(:site_id => site_id)
    ar_divisions = Division.where(:site_id => site_id).order('name ASC')
    total_revenue= {}
    series_data= {}
    ar_divisions.each do |division|        
      hr_division = hourly_revenues.detect{ |hr| hr.division_id == division.id }
      data = (0..23).to_a.reverse.collect do |k|
        #
        # I wasn't expecting for 'hr_division.revenue["%02d"%k]' to be nil, but it is (Santiago)
        #
        revenue= hr_division && hr_division.revenue["%02d"%k] ? hr_division.revenue["%02d"%k] : 0
        total_revenue[division.name]= revenue+(total_revenue[division.name]||0)
        revenue
      end
      series_data[division.name]= data
    end
    total_revenue.sort {|a,b| b[1]<=>a[1]}.each do |t|
      chart[:series] << { :name => t[0], :data => series_data[t[0]] }
    end
    chart
  end
  
  private   

  def self.init_chart
    today= Time.now
    chart = {
      :categories => (0..23).map { |t| "#{(today-t.hours).hour}:00" }.reverse,
      :series => []
    }       
    chart
  end
end
