class Chart
  def initialize(sites = [])
    if !sites.empty?
      @snapshots = Snapshot.recent.find(:all, :conditions => ["site_id in(?)", sites.map(&:id)])
    else
      @snapshots = Snapshot.recent
    end
  end
  
  def labels
    @labels ||= @snapshots.map{|s| s.site.name }
  end
  
  def revenue_per_hour
    revenue= {}
    current_time= Time.now
    Site.all.each do |site|
      revenue[site.name]={}
      22.times do |t|
        revenue[site.name][current_time-(t+2)]= site.revenue_per_hour(current_time-(t+2).hour)
      end
    end
    revenue
  end

  def datasets
    @snapshots.group_by{ |s| 
      s.created_at.strftime("%H") 
    }.map{ |h,s| 
      [s.first.site.name,s.sum(&:sold_count)]
    }
  end
end
