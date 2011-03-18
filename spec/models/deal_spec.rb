require 'spec_helper'

describe Deal do
  it{ should have_many(:snapshots) }
  it{ should belong_to(:site) }
  it{ should belong_to(:division) }
  it{ should validate_uniqueness_of(:deal_id) }
  
  before(:each) do
    @deal = Factory(:deal)
  end
  
  
  context "calculations" do
    it "should calcuate revenue" do
      @deal.should_receive(:buyers_count)
      @deal.should_receive(:sale_price)
      @deal.revenue
    end
  end
  
  context "importing" do
    it "should generate a unique deal id" do
      deal = Factory.create(:deal)
      unique_key = Digest::MD5.hexdigest(deal.name + deal.permalink + deal.expires_at.to_s)
      deal.deal_id.should == unique_key
    end
  end
end