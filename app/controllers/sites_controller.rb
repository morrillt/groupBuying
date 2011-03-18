class SitesController < ApplicationController
  # GET /sites
  # GET /sites.xml
  def index
    @chart = Chart.new
    @sites = Site.active

    @chart_data= Chart.hourly_revenue_by_site
    # puts @chart_data.inspect

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @sites }
    end
  end

  # GET /sites/1
  # GET /sites/1.xml
  def show
    @site = Site.find_by_source_name(params[:id])
    @chart_data= Chart.hourly_revenue_by_divisions(@site.id)
    respond_to do |format|

      format.html # show.html.erb
      format.xml  { render :xml => @site }
    end
  end
end
