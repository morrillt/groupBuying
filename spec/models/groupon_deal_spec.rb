require 'spec_helper'

describe GrouponDeal do

  describe ".active" do
    it "returns the active deals" do
      GrouponDeal.active.each { |deal| deal.status.should == "1" }
    end
  end

  describe ".closed" do
    it "returns the closed deals" do
      GrouponDeal.closed.each { |deal| deal.status.should == "0" }
    end
  end

  describe ".today" do
    it "returns the deals that have today as a datadate" do
      GrouponDeal.today.each { |deal| deal.datadate.should == Date.today }
    end
  end

  describe ".by_deal" do
    subject { GrouponDeal.by_deal("beyouteful") }
    it "returns all the deals with the given ID" do
      subject.length.should_not == 0
      subject.each { |deal| deal.deal_id.should == "beyouteful" }

    end
    it "includes the deal_id and location" do
      subject.first.deal_id.should == "beyouteful"
      subject.first.location.should == "S7K"
    end

    it "sorts the records in order" do
      subject.first.datadate.should > subject.last.datadate
    end
  end

  describe ".yesterday" do
    subject { GrouponDeal.yesterday }

    it { subject.length.should_not == 0 }
    it "returns the deals that have yesterday as a datadate" do
      subject.each { |deal| deal.datadate.should == Date.today - 1.day }
    end
  end

  describe ".unique" do
    let(:deal) { GrouponDeal.unique.find_by_deal_id_and_datadate("beyouteful", Date.today) }
    subject { GrouponDeal.unique.map(&:deal_id) }
    it "returns the deals a list of deals without the same id" do
      subject.length.should == GrouponDeal.all.map(&:deal_id).uniq.length
    end

    it "gets the latest deals" do
      GrouponDeal.unique.find_all_by_deal_id("beyouteful").length.should == 1
      GrouponDeal.unique.find_by_deal_id("beyouteful").count.should == deal.count
    end
  end

  describe ".zip_codes" do
    it "returns the zip codes for all the promos in the DB" do
      GrouponDeal.zip_codes.map(&:location).should == ["95060", "S7K", "31401-1119", "98109"]
    end
  end

  describe ".num_coupons" do
    context "with params" do
      it "returns the number of coupons for a given range" do
        GrouponDeal.num_coupons(:today).should == 2236
      end
    end

    context "without params" do
      it "returns the number of coupons for all the deals" do
        GrouponDeal.num_coupons.should == 4119
      end
    end

  end
  describe ".spent" do
    context "with params" do
      it "returns the total of money spent on the deals for a given range" do
        GrouponDeal.spent(:today).should == 40216
      end
    end

    context "without params" do
      it "returns the total money spent on Groupon" do
        GrouponDeal.spent.should == 74179
      end
    end
  end

  describe ".average_revenue" do
    context "with params" do
      it "returns the average revenue (spent / num_coupons) for a given range" do
        GrouponDeal.average_revenue(:yesterday).should == 12025
      end
    end

    context "without params" do
      it "returns the average revenue (spent / num_coupons) for all time" do
        GrouponDeal.average_revenue.should == 10597
      end
    end
  end

  describe ".chart_data" do
    it "" do
      GrouponDeal.chart_data
    end
  end

  describe "#hotness_index" do
    let(:deal) { GrouponDeal.find_by_deal_id("beyouteful") }
    subject { deal.hotness_index }
    it { should == 2075 }
  end


end


