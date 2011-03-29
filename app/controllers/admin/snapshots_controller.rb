class Admin::SnapshotsController < Admin::ApplicationController
  layout "admin"
  
  def index
    @model_name= 'deal_snapshot'
  end
  
  def show
    @snapshot = Snapshot.find(params[:id])
  end
end
