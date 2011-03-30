class Admin::SitesController < Admin::ApplicationController
  def index
    @sites = Site.all
  end
  
  def show
    @site = Site.find(params[:id])
    @site_hourly_revenue_by_site = HourlyRevenueBySite.where(:site_id => params[:id]).limit(5)
    
    paginated_options = {:page => (params[:page] || 1), :per_page => 30}
    if params[:query]
      paginated_options.merge!(:conditions => ["deals.id = ? or deals.name like ?", params[:query], '%'+params[:query]+'%'])
    end
    
    @deals = @site.deals.paginate(paginated_options)
  end
end