class Admin::DealsController < Admin::ApplicationController
  def index
    @deals = Deal.paginate(:per_page => 25, :page => (params[:page] || 1), :include => [:site, :division])
  end
  
  def show
    @deal = Deal.find(params[:id])
  end
end