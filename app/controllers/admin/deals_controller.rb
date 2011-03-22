class Admin::DealsController < Admin::ApplicationController
  layout "admin"
  
  def index
    # todo need a way to show inactive deals too.
    @deals = Deal.active.paginate(:per_page => 25, :page => (params[:page] || 1), :include => [:site, :division, :snapshots])
  end
  
  def show
    @deal = Deal.find(params[:id], :include => [:site, :division, :snapshots])
  end
  
  def export
    @deals = Deal.active.find(:all, :include => [:division, :site], :conditions => ["created_at between ? and ?", 1.day.ago.at_midnight, Time.now])
    
    FasterCSV.open('public/deals.csv','w+') do |csv|
      csv << %w(id name url sale_price actual_price division site active hotness lat lng expires_at raw_address sold_count)
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
          deal.raw_address,
          deal.buyers_count
        ]
      end
    end
    
    send_file("public/deals.csv", :content_type => "text/csv", :disposistion => "inline", :filename => "deals.csv")
  end
end