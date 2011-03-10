class SnapshotsController < InheritedResources::Base
  belongs_to :site, :finder => :find_by_name
  
  def collection
    @snapshots = parent.snapshots.desc(:created_at).paginate(:page => params[:page])
  end
end