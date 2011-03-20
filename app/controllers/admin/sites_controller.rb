class Admin::SitesController < Admin::ApplicationController
  layout "admin"
  
  def index
    @sites = Site.paginate(:per_page => 25, :page => (params[:page] || 1))
  end
  
  def show
    @site = Site.find(params[:id])
  end
end