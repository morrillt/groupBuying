require 'spec_helper'

describe Snapshooter::KgbDeals do
  before(:each) do
    @kgb_deals = Snapshooter::KgbDeals.new
    @kgb_deals.stub(:capture_sold_count).and_return(300)
  end
  
  context "a get request" do
    it "should query the sitemap for divisions" do
      @kgb_deals.should_receive(:get).with("/sitemap")
      @kgb_deals.divisions
    end
  end
  
  context "crawl_new_deals" do
    before(:each) do
      @kgb_deals.stub(:divisions).and_return([{:href => 'http://google.com', :text => 'google'}])
    end
    
    it "should get a division" do
      @kgb_deals.should_receive(:get).with('http://google.com')
      @kgb_deals.crawl_new_deals!
    end
    
  end
end