class Admin::SitesController < Admin::ApplicationController
  layout "admin"
  
  def index
    @model_name= 'site'
  end

  def show
    @site = Site.find(params[:id])
  end
end
