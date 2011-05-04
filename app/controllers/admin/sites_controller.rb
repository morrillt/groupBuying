class Admin::SitesController < Admin::ApplicationController
  def index
    @sites = Site.includes(:deals)
  end
  
  def show
    @site = Site.includes(:deals, :divisions).find(params[:id])

    paginated_options = {:page => (params[:page] || 1), :per_page => 30}
    if params[:search]
      paginated_options.merge!(:conditions => ["deals.id = ? or deals.name like ?", params[:search], '%'+params[:search]+'%'])
    end
    
    @deals = @site.deals.includes(:categories, :division, :site).order('active DESC, hotness DESC').paginate(paginated_options)
    @active_deals = @deals.select{|deal| deal.active == 1}
    @inactive_deals = @deals.select{|deal| deal.active == 0}
    
    @closed_from = Deal.inactive.where(:site_id => @site.id).minimum('expires_at')
    @closed_to = Deal.inactive.where(:site_id => @site.id).maximum('expires_at')
    @closed_avg_rev = if @site.deals.inactive.count == 0
      0 
    else
      @site.deals.inactive.revenue_by_max_sold_count.first.revenue_ms / @site.deals.inactive.count
    end
  end
end