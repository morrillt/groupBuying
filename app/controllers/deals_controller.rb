class DealsController < ApplicationController
  # GET /deals
  # GET /deals.xml
  def index
    render_404 && return if params[:site_id].nil?
    
    @site = Site.find(params[:site_id])
    @deals = @site.deals.active.paginate(:page => (params[:page] || 1), :per_page => 25, :include => [:site, :division, :snapshots])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @deals }
    end
  end

  # GET /deals/1
  # GET /deals/1.xml
  def show
    @deal = Deal.find(params[:id], :include => [:site, :division, :snapshots])
    @chart = Chart.new(@deal)

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @deal }
    end
  end
end
