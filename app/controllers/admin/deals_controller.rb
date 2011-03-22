class Admin::DealsController < Admin::ApplicationController
  layout "admin"
  
  def index
    @model_name= 'deal'
  end
  
  def show
    @deal = Deal.find(params[:id], :include => [:site, :division, :snapshots])
  end
  
  def export
    @deals = Deal.active.find(:all, :include => [:division, :site])
    
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
