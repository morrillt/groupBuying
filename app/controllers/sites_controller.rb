class SitesController < ApplicationController
  # GET /sites
  # GET /sites.xml
  def index
    @chart = Chart.new
    @sites = Site.active

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @sites }
    end
  end

  # GET /sites/1
  # GET /sites/1.xml
  def show
    @site = Site.find(params[:id])
    @chart = Chart.new([@site])
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @site }
    end
  end
end
