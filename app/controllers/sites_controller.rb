class SitesController < ApplicationController
  # GET /sites
  # GET /sites.xml
  def index
    @chart = Chart.new
    @sites = Site.active

    @chart_data= Chart.hourly_renevue_by_site
    # puts @chart_data.inspect

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @sites }
    end
  end

  # GET /sites/1
  # GET /sites/1.xml
  def show
    @site = Site.find_by_source_name(params[:source_name])

    @data = Deal.get_info(@site)
    # @data[:locations] = @site.divisions.all.length.to_s



    @chart = Chart.new([@site])
    

    respond_to do |format|

      format.html # show.html.erb
      format.xml  { render :xml => @site }
    end
  end
end
