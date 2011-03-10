class SnapshotsController < InheritedResources::Base
  belongs_to :site, :finder => :find_by_name
  
  def collection
    @snapshots = parent.snapshots.recent.desc(:created_at).limit(100)
  end
end