class Admin::DivisionsController < Admin::ApplicationController
  layout "admin"
  
  def index
    @divisions = Division.paginate(:per_page => 25, :page => (params[:page] || 1))
  end
  
  def show
    @division = Division.find(params[:id])
  end
end