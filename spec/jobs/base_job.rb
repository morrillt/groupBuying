require 'spec_helper'

describe BaseJob do
  before(:each) do
    ResqueSpec.reset!
    @job = BaseJob.create
  end

  it "should have SPLIT constants" do
    BaseJob.constants.should include('SPLIT_CRAWL_FOR')
    BaseJob.constants.should include('SPLIT_SNAPSHOTS_FOR')
  end                                
  
  it "should enqueue job class by site" do
    # BaseJob.should have_queue_size_of(1)    
    # @job.enqueue_by_site
    # BaseJob.should have_queue_size_of(Site.active.count)
    # Site.active.each {|site|
    #   BaseJob.should have_queued(site.id)
    # }    
  end

end
