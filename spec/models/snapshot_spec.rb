require 'spec_helper'

describe Snapshot do
  before(:each) do
    # hack for issue with no test db
    Rails.env.stub(:test?).and_return(true)
    
    @snapshot = Factory(:snapshot)
  end
  
  it{ should belong_to(:site) }
  it{ should belong_to(:deal) }
  
  context "scopes" do
    it "should find recent snapshots" do
      recent_snapshot = Factory.create(:snapshot, :created_at => 1.day.ago)
      Snapshot.recent.include?( recent_snapshot ).should be_true
    end
  end
  
  context "scoped attributes" do
    it "should return site_name" do
      @snapshot.site.should_receive(:name)
      @snapshot.site_name
    end
    
    it "should return deal_name" do
      @snapshot.deal.should_receive(:name)
      @snapshot.deal_name
    end
    
    it "should return price" do
      @snapshot.deal.should_receive(:try).with(:sale_price)
      @snapshot.price
    end
    
    it "should alias buyers_count to sold count" do
      @snapshot.should_receive(:sold_count)
      @snapshot.buyers_count
    end
    
    it "should return total revenue correctly" do
      @snapshot.stub(:price).and_return(19.99)
      @snapshot.stub(:buyers_count).and_return(473)
      @snapshot.total_revenue.should == (@snapshot.price.to_f * @snapshot.buyers_count.to_f)
    end
    
    it "should calculate hotness as 80.0%" do
      snapshot = Factory(:snapshot, :sold_count => 20)
      Factory(:snapshot, :sold_count => 100, :deal_id => snapshot.deal.id)
      snapshot.calculate_hotness
      snapshot.deal.hotness.should == 80.0
    end
    
    it "should calculate hotness as 65.0%" do
      snapshot = Factory(:snapshot, :sold_count => 35)
      Factory(:snapshot, :sold_count => 100, :deal_id => snapshot.deal.id)
      snapshot.calculate_hotness
      snapshot.deal.hotness.should == 65.0
    end
    
    it "should calculate hotness as 15.0%" do
      snapshot = Factory(:snapshot, :sold_count => 85)
      Factory(:snapshot, :sold_count => 100, :deal_id => snapshot.deal.id)
      snapshot.calculate_hotness
      snapshot.deal.hotness.should == 15.0
    end
  end
end