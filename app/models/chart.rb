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
  
  def datasets
    @snapshots.group_by{ |s| 
      s.created_at.strftime("%H") 
    }.map{ |h,s| 
      [s.first.site.name,s.sum(&:sold_count)]
    }
  end
end