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
  
  context "scopes" do
    describe ".active" do            
      it "should return records where #active == true" do
        deal = Factory.create(:deal, :active => true)
        
        Deal.active.should include(deal)
      end

      it "should not return records where #active == false" do
        deal = Factory.create(:deal, :active => false)
        
        Deal.active.should_not include(deal)
      end
    end

    describe ".expired" do
      it "should return records where #expires_at == NOW() - days" do
        deal = Factory.create(:deal, :expires_at => Time.now - 1.days)
        
        Deal.expired.should include(deal)
      end
      it "should not return records where #expires_at == NOW() + days" do
        deal = Factory.create(:deal, :expires_at => Time.now + 1.days)
        
        Deal.expired.should_not include(deal)
      end
    end
    
  end
end