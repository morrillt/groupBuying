class Chart
  # Returns a hash containing the revenue for each
  # hour during the last 24 hours, for each site
  def self.hourly_revenue_by_site
    today= Time.now
    chart= {
      :categories => (1..24).map { |t| "#{(today-t.hours).hour}:00" }.reverse,
      :series => []
    }           
    Site.includes(:hourly_revenue_by_site).active.each do |site|
      data = site.hourly_revenue_by_site.sort_by(&:order).reverse.collect(&:revenue)
      chart[:series] << { :name => site.name, :data => data } 
    end
    chart
  end

  def self.hourly_revenue_by_divisions(site_id)
    site= Site.find(site_id)
    divisions= site.divisions
    today= Time.now
    chart= {
      :categories => (1..24).map { |t| "#{(today-t.hours).hour}:00" }.reverse,
      :series => []
    }
    pre_data= {}
    divisions_names= []
    divisions.each do |d|
      revs= (1..24).map { 0 }
      divisions_names << d.name
      pre_data[d.name]= {:name=> d.name, :revs => revs}
    end

    (1..24).map do |t|
      today= Time.now-t.hours # should not be Time.now
      revenues= site.revenue_for_all_divisions_by_given_hour_and_date(today.hour, today)
      revenues.each do |r|
        pre_data[r.name][:revs][t]= r.rev.to_f
      end
    end
    divisions_names.sort!
    divisions_names.each do |d|
      chart[:series] << { :name => d, :data => pre_data[d][:revs].reverse! }
    end
    chart
  end
end
