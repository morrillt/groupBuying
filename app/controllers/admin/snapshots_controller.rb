class Admin::SnapshotsController < Admin::ApplicationController
  def index
    @snapshots = Snapshot.paginate(:per_page => 25, :page => (params[:page] || 1))
  end
  
  def show
    @snapshot = Snapshot.find(params[:id])
  end
end