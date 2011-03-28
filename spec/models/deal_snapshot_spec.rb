require 'spec_helper'

describe DealSnapshot do
  before(:each) do
    @deal = Factory(:deal)
    @deal_snapshot = Factory(:deal_snapshot, :deal_id => @deal.id, :buyers_count => 100)
    @deal.site.snapshooter.stub(:capture_deal).and_return(10)
  end
  
  it "should not create a snapshot for an expired deal" do
    @deal.expires_at = 1.month.ago
    DealSnapshot.create_from_deal!(@deal).should be_false
  end
end