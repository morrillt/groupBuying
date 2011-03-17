class Chart
  def initialize(sites = nil)
    @snapshots = Snapshot.recent
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