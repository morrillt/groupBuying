require 'spec_helper'

describe CrawlerJob do
  before(:each) do
    ResqueSpec.reset!
  end

  it "adds sites to the CrawlerJob queue" do
    CrawlerJob.perform            
    CrawlerJob.should have_queue_size_of(Site.active.count)    
    Site.active.each {|site|
      CrawlerJob.should have_queued(site.id).in(:crawler)
    }
  end
  
  it "should crawl_new_deals!" do
    # TODO: add test for crawling site deals work
    with_resque do
    end                                             
    pending
  end  

end
