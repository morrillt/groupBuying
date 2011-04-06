class Admin::DealsController < Admin::ApplicationController
  layout "admin"
  
  def index
    @model_name= 'deal'
  end
  
  def show
    @deal = Deal.find(params[:id], :include => [:site, :division])
    @snapshots = DealSnapshot.where(:deal_id => @deal.id).order('created_at ASC')
  end
  
  def export
    respond_to do |format|
      format.html { render :text => ''}
      format.xml  { render :xml => @deals }
      format.csv  { 
        headers["Content-Type"] = 'text/csv'
        render :text => Deal.export(:site_id => params[:site_id]), :layout => false
      }
    end
    
  end
end
