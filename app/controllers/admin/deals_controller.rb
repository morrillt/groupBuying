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
    
    render_404 && return unless File.exists?("public/deals.csv")
    
    send_file("public/deals.csv", :content_type => "text/csv", :disposistion => "inline", :filename => "deals.csv")
  end
end