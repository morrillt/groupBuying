class SitesController < ApplicationController # InheritedResources::Base #
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
    @site = Site.find_by_source_name(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @site }
    end
  end

  def resource
    @site = Site.find_by_source_name(params[:id])
  end
end
