class SitesController < ApplicationController
  # GET /sites
  # GET /sites.xml
  def index
    @chart = Chart.new
    @sites = Site.active

    @chart_data= Chart.hourly_revenue_by_site

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @sites }
    end
  end

  # GET /sites/1
  # GET /sites/1.xml
  def show
    @site = Site.find_by_source_name(params[:id])
    @data = @site.get_info
    @data[:locations] = @site.divisions.length
    @chart_data= Chart.hourly_revenue_by_divisions(@site.id)
    @trending= @site.currently_trending
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @site }
    end
  end

  def coupons_count
    count= Site.coupons_purchased_to_date
    respond_to do |format|
      format.json { render :json => {:coupons_count => count} }
    end
  end
end
