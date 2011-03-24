require 'spec_helper'

describe SnapshotJob do
  before(:each) do
    ResqueSpec.reset!
  end

  it "adds sites to the SnapshotJob queue" do
    SnapshotJob.perform            
    SnapshotJob.should have_queue_size_of(Site.active.count)    
    Site.active.each {|site|
      SnapshotJob.should have_queued(site.id).in(:snapshot)
    }
  end    
  
  
  it "should update_snapshots!" do
    # TODO: add test for snapshots updating work
    with_resque do 
    end                                             
    pending
  end

end
