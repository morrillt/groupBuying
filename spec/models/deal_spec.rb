require 'spec_helper'

describe Deal do
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
    
    it "should calculate hotness as 80.0%" do
      Factory(:deal_snapshot, :buyers_count => 20, :deal_id => @deal.id)
      Factory(:deal_snapshot, :buyers_count => 100, :deal_id => @deal.id)
      @deal.calculate_hotness!
      @deal.hotness.should == 80.0
    end
    
    it "should calculate hotness as 65.0%" do
      Factory(:deal_snapshot, :buyers_count => 35, :deal_id => @deal.id)
      Factory(:deal_snapshot, :buyers_count => 100, :deal_id => @deal.id)
      @deal.calculate_hotness!
      @deal.hotness.should == 65.0
    end
    
    it "should calculate hotness as 15.0%" do
      Factory(:deal_snapshot, :buyers_count => 85, :deal_id => @deal.id)
      Factory(:deal_snapshot, :buyers_count => 100, :deal_id => @deal.id)
      @deal.calculate_hotness!
      @deal.hotness.should == 15.0
    end
  end
  
  context "importing" do
    it "should generate a unique deal id" do
      deal = Factory.create(:deal)
      unique_key = Digest::MD5.hexdigest(deal.name + deal.permalink + deal.expires_at.to_s)
      deal.deal_id.should == unique_key
    end
    
     it "should not save a duplicate" do
        deal = Factory.create(:deal)
        unique_key = Digest::MD5.hexdigest(deal.name + deal.permalink + deal.expires_at.to_s)
        Deal.create(:deal_id => unique_key).errors.on(:deal_id).should == 'has already been taken'
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

  context "geocoding" do
    describe "#geocode_lat_lng!" do
      it "should capture all decimals for lat and lng" do
        deal = Factory.create(:deal, :active => true, :raw_address => "Salon Roi 2602 Connecticut Ave. NW Washington, DC 20008")
        puts deal.inspect
      end
    end
  end
end
