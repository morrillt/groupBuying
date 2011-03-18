require 'spec_helper'

describe Site do
  before(:each) do
    @site = Factory(:site, :source_name => 'kgb_deals')
  end
  
  it{ should have_many(:deals) }
  it{ should have_many(:divisions) }
  
  context "scopes" do
    it "should find active sites" do
      @site.update_attribute(:active, true)
      Site.active.include?(@site).should be_true
    end
  end
  
  context "snapshots" do
    it "should only snapshot active deals" do
      @site.deals.should_receive(:active).and_return([])
      @site.update_snapshots!
    end
  end
  
  context "crawler" do
    it "should call snapshooter.crawl_new_deals! when site.crawl_new_deals" do
      @site.snapshooter.stub(:crawl_new_deals!).and_return(nil)
      @site.snapshooter.should_receive(:crawl_new_deals!)
      @site.crawl_new_deals
    end
    
    it "should return an instance of the correct snapshooter" do
      @site.snapshooter.class.should == Snapshooter::KgbDeals
    end
  end
end