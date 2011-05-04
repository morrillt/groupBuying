require 'spec_helper'
                      
module Snapshooter
  describe Crawler do
    before(:each) do
      @site = Site.create :name=> 'test', :source_name=> 'test', :base_url=> 'http://test.com', :active=>true
      @crawler = Crawler.new('test')
    end

    after(:each) do
      Site.delete(@site.id)
    end

    it "should have LIMIT constants" do
      Crawler.constants.should include('DIVISION_LIMIT')
      Crawler.constants.should include('DEAL_LIMIT')
    end                                         
    
    it "should return site" do
      @crawler.site.should be_kind_of Site
    end
    
    context "crawling" do
    end
    
    context "brute-crawling" do 
    end
    
    context "udpdate deals info" do
    end
    
  end
end
