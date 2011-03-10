class SnapshotDiffsController < InheritedResources::Base
  belongs_to :site, :finder => :find_by_name
  
  def collection
    @snapshot_diffs ||= parent.snapshot_diffs.order(:changed_at.desc).paginate(:page => params[:page])
  end
end