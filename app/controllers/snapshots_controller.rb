class SnapshotsController < InheritedResources::Base
  belongs_to :site, :finder => :find_by_name
  
  def show
    render :inline => resource.raw_data
  end
  
  def collection
    @snapshots = parent.snapshots.desc(:created_at).paginate(:page => params[:page])
  end
end