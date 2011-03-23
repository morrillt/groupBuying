require 'spec_helper'

describe DealCloserJob do
  it "close deal when it expires" do
    @deal = Deal.new
    @deal.stub(:active).and_return(true)    
    @deal.stub(:expires_at).and_return(Time.now - 1.days)    
    Deal.stub_chain(:expired, :active).and_return([@deal])
    
    with_resque do 
      DealCloserJob.perform
    end
    @deal.should_not be_active
    @deal.should be_sold    
  end

end