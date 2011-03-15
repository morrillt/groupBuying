require 'spec_helper'

describe SnapshotDiff do
  
  before :each do
    @deal          = Factory(:deal)
    @snapshot      = Factory(:snapshot)
    @snapshot_diff = Factory(:snapshot_diff, :deal_id => @deal.id)
  end
  
  it "should find a snapshot" do
    Snapshot.stub(:find).and_return(@snapshot)
    @snapshot_diff.snapshot.should == @snapshot
  end
end