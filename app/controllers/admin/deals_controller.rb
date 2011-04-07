class Admin::DealsController < Admin::ApplicationController
  layout "admin"
  
  def index
    @model_name= 'deal'
  end
  
  def show
    @deal = Deal.find(params[:id], :include => [:site, :division])
    @snapshots = DealSnapshot.where(:deal_id => @deal.id).order_by([:created_at, :asc])
  end
  
  def export              
    opts = {:site_id => params[:site_id]}       
    opts.merge!({:active => params[:active]}) if params[:active]
    respond_to do |format|
      format.html { render :text => ''}
      format.xml  { render :xml => @deals }
      format.csv  { 
        headers["Content-Type"] = 'text/csv'
        headers['Content-Disposition'] = "attachment; filename=\"closed_deals-#{Time.now.strftime("%m-%d-%Y")}\"" 
        render :text => Deal.order('expires_at ASC').export(opts), :layout => false
      }
    end
    
  end
end
