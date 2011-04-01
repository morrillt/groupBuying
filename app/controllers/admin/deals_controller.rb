class Admin::DealsController < Admin::ApplicationController
  layout "admin"
  
  def index
    @model_name= 'deal'
  end
  
  def show
    @deal = Deal.find(params[:id], :include => [:site, :division])
  end
  
  def export
    redirect_to '/deals.csv'
  end
end
