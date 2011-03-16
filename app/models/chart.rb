class Chart
  def initialize(sites = nil)
    @snapshots = Snapshot.recent
  end
  
  def labels
    @labels ||= @snapshots.map{|s| s.site.name }.uniq.map{|name| "data.addColumn('string', '#{name}')"}.join(",")
  end
  
  def data
    @snapshots.group_by{ |s| 
      s.created_at.strftime("%H") 
    }.map{ |h,s| 
      "['#{h}', #{s.sum(&:sold_count)}]" 
    }.join(",")
  end
end