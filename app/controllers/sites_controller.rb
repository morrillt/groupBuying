class SitesController < InheritedResources::Base
  include ChartableController
  
  def collection
    @sites  ||= Site.active
  end
  
  def show
    @site     = Site.find_by_name(params[:id], :include => :snapshot_diffs)
    
    @activity       = @site.activity_block(params.slice(:from, :to))
    @past_activity  = @site.activity_block(:from => @activity.from - 1.day, :to => @activity.to - 1.day)

    @comparison = Comparison.new(@activity, @past_activity)
    @hot_deals  = @site.deals.hot.limit(10)
  end
  
end