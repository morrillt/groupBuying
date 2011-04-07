class Admin::SitesController < Admin::ApplicationController
  def index
    @sites = Site.all
  end
  
  def show
    @site = Site.find(params[:id])

    paginated_options = {:page => (params[:page] || 1), :per_page => 30}
    if params[:search]
      paginated_options.merge!(:conditions => ["deals.id = ? or deals.name like ?", params[:search], '%'+params[:search]+'%'])
    end
    
    @deals = @site.deals.order('active DESC, hotness DESC').paginate(paginated_options)
    @closed_from = Deal.inactive.where(:site_id => @site.id).minimum('expires_at')
    @closed_to = Deal.inactive.where(:site_id => @site.id).maximum('expires_at')
    @closed_avg_rev = if @site.deals.inactive.count == 0
      0 
    else
      @site.deals.inactive.revenue_by_max_sold_count.first.revenue_ms / @site.deals.inactive.count
    end
  end
end