require 'spec_helper'

describe DealSnapshot do
  before(:each) do
    @deal = Factory(:deal)
    @deal_snapshot = Factory(:deal_snapshot, :deal_id => @deal.id, :buyers_count => 100)
  end
  
  it "should populate values on save" do
    @deal_snapshot.should_receive(:last_buyers_count=).with(100)
    @deal_snapshot.save
  end
end