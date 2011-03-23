require 'spec_helper'

describe DealCloserJob do

  it "close deal when it expires" do
    @deal = Deal.new
    @deal.stub(:expires_at).and_return(Time.now - 1.days)    
    Deal.stub(:active).and_return([@deal])
    
    with_resque do 
      DealCloserJob.perform
    end
    @deal.should_not be_active
    @deal.should be_sold    
  end

  it "not close deal if it not expired" do
    @deal = Deal.new
    @deal.stub(:expires_at).and_return(Time.now + 1.days)    
    Deal.stub(:active).and_return([@deal])
    
    with_resque do 
      DealCloserJob.perform
    end
    @deal.should be_active
    @deal.should_not be_sold    
  end

end
