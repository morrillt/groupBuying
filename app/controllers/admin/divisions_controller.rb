class Admin::DivisionsController < Admin::ApplicationController
  layout "admin"
  
  def index
    @model_name= 'division'
  end
  
  def show
    @division = Division.find(params[:id])
  end
end
