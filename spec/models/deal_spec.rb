require 'spec_helper'

describe Deal do
  it{ should have_many(:snapshots) }
  it{ should belong_to(:site) }
  it{ should belong_to(:division) }
  
  before(:each) do
    @deal = Factory(:deal)
  end
  
  context "calculations" do
    it "should calcuate revenue" do
      @deal.should_receive(:buyers_count)
      @deal.should_receive(:sale_price)
      @deal.revenue
    end
    
    
    
    # TODO:
    # This is slowing tests due to the capture_snapshot callback
    #it "should calculate the buyers_count" do
    #  snapshot = Factory(:snapshot, :deal => @deal, :sold_count => 300)
    #  @deal.stub(:capture_snapshot).and_return(300)
    #  @deal.buyers_count.should == 300
    #end
  end
end