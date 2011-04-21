require 'spec_helper'
                      
module Snapshooter
  describe Crawler do
    before(:each) do
      @site = Site.create :name=> 'test', :source_name=> 'test', :base_url=> 'http://test.com', :active=>true
      @crawler = Base.new('some_crawler')
    end

    after(:each) do
      Site.delete(@site.id)
    end

    it "should have LIMIT constants" do
      Base.constants.should include('DIVISION_LIMIT')
      Base.constants.should include('DEAL_LIMIT')
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
