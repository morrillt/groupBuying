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
    
    @deals = @site.deals.paginate(paginated_options)
  end
end