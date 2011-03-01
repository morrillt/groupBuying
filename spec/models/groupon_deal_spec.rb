require 'spec_helper'

describe GrouponDeal do
  describe ".active" do
    it "returns the active deals" do
      GrouponDeal.active.each {|deal| deal.status.should == "1" }
    end
  end

  describe ".closed" do
    it "returns the closed deals" do
      GrouponDeal.closed.each {|deal| deal.status.should == "0" }
    end
  end

  describe ".today" do
  end
  describe ".unique"
  describe ".zip_codes"
  describe ".num_coupons"
  describe ".spent"
  describe ".average_revenue"
end
