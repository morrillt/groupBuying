class DealsController < ApplicationController
  # GET /deals
  # GET /deals.xml
  def index
    render_404 && return if params[:site_id].nil?
    
    @site = Site.find(params[:site_id])
    @deals = @site.deals.active.paginate(:page => (params[:page] || 1), :per_page => 25)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @deals }
    end
  end

  # GET /deals/1
  # GET /deals/1.xml
  def show
    @deal = Deal.find(params[:id])
    @chart = Chart.new(@deal)

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @deal }
    end
  end

  def export
    @deals = Deal.find(:all, :conditions => "active = 1", :include => [:division, :site])
    
    FasterCSV.open('public/deals.csv','w+') do |csv|
      csv << %w(id name url sale_price actual_price division site active hotness lat lng expires_at raw_address)
      @deals.each do |deal|
        csv << [
          deal.id,
          deal.name,
          deal.permalink,
          deal.sale_price,
          deal.actual_price,
          deal.division_name,
          deal.site_name,
          deal.active,
          deal.hotness,
          deal.lat,
          deal.lng,
          deal.expires_at,
          deal.raw_address
        ]
      end
    end
    
    send_file("public/deals.csv", :content_type => "text/csv", :disposistion => "inline", :filename => "deals.csv")
  end
end
