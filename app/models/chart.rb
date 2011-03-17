class Chart
  # Accepts an array of deals or sites
  def initialize(objects = [])
    @objects = objects
    # wrap non array classes in an array
    @objects = [@objects].compact unless @objects.is_a?(Array)    
    
    if !@objects.empty?
      # either site_id or deal_id
      fk = "#{@objects.first.class.to_s.downcase}_id"
      @snapshots = Snapshot.recent.find(:all, :conditions => ["#{fk} in(?)", @objects.map(&:id)])
    else
      @snapshots = Snapshot.recent
    end
    
    # Group data by hour created
    @snapshots_by_hour = @snapshots.group_by{ |s| s.created_at.strftime("%H") }
  end
  
  def labels
    @labels ||= @snapshots_by_hour.map{|h,s| h }.uniq!
  end
  
  def datasets
    @snapshots.group_by(&:site).map do |site, snapshots|
      [site.name, 
      snapshots.group_by{|s| s.created_at.strftime("%H") }.map do |h, snapshots|
        snapshots.map(&:total_revenue)
      end.flatten
      ]
    end
  end
end