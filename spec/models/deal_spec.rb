require 'spec_helper'

describe Deal do
  
  before :each do
    @deal = Factory(:deal, :deal_id => 1)
  end
  
  it "should return deal_id as chart_name" do
    @deal.chart_name.should == 1
  end
  
  it "should return lat long as array for location" do
    @deal.location.should == [@deal.latitude, @deal.longitude]
  end
  
  it "should set the location" do
    @deal.should_receive(:latitude=).with(5)
    @deal.should_receive(:longitude=).with(6)
    @deal.location = [5,6]
  end
end