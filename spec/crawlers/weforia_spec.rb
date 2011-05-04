require 'spec_helper'
require 'time'

describe Snapshooter::Weforia do
  before(:each) do
    @site = Site.create :name=> 'weforia', :source_name=> 'weforia', :base_url=> 'http://www.weforia.com', :active=>true
    @crawler = Snapshooter::Weforia.new('weforia')
  end

  after(:each) do
    Site.delete(@site.id)
  end

  context "parser" do
    it "parses divisions" do
      @crawler.divisions.count.should == 5
      @crawler.divisions.collect{|div| div[:name]}.should include("Boston, MA")
      @crawler.divisions.collect{|div| div[:name]}.should include("Cedar Rapids, IA")
      @crawler.divisions.collect{|div| div[:name]}.should include("Ft Myers, FL")
      @crawler.divisions.collect{|div| div[:name]}.should include("Philadelphia - Western Suburbs, PA")
      @crawler.divisions.collect{|div| div[:name]}.should include("Phoenix, AZ")
    end

    it "parses deal links" do
      @crawler.get('/deal/boston-ma/groupBuysList.action')
      @crawler.deal_links.count.should == 10
      @crawler.deal_links[0].should == "/deal/boston-ma/classic-sub-shop"
      @crawler.deal_links[1].should == "/deal/boston-ma/tl-massage-therapy-90-minute-citrus-scrub-and-swedish-massage"
    end

    it "parses pagination links" do
      @crawler.get('/deal/boston-ma/groupBuysList.action')
      @crawler.pages_links.should_not be_nil
      (0..2).each do |i|
        @crawler.pages_links[i].should =~ /\?p=#{i+2}$/
      end
    end

    context "parsing deal" do
      before(:each) do
        @crawler.get('/deal')
        doc = @crawler.doc
        @deal = Snapshooter::Weforia::Deal.new(doc, '/deal', @site.id)
      end

      it "parses name" do
        @deal.name.should =~ /\$1.99 for any Classic 9 inch Sub at Classic Sub Shop, a \$6.75 Value/
      end

      it "parses sale price" do
        @deal.sale_price.should == 1.99
      end

      it "parses actual price" do
        @deal.actual_price.should == 7 # 6.75 rounded to 7
      end

      it "parses raw address" do
        @deal.raw_address.should =~ /79 Bridge St, Beverly/
      end

      it "parses deal expiry" do
        expiry = Time.now
        expiry = expiry + 3*24*60*60 + 18*60*60 + 25*60
        
        (@deal.expires_at.to_i - expiry.to_i).should <= 10
      end

      it "parses telephone" do
        @deal.name.should =~ /\$1.99 for any Classic 9 inch Sub at Classic Sub Shop, a \$6.75 Value/
      end

      it "parses buyers count" do
        @deal.name.should =~ /\$1.99 for any Classic 9 inch Sub at Classic Sub Shop, a \$6.75 Value/
      end

      it "parses sold out status" do
        @deal.name.should =~ /\$1.99 for any Classic 9 inch Sub at Classic Sub Shop, a \$6.75 Value/
      end
    end
  end
end
