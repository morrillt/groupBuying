require 'spec_helper'

describe Snapshooter::Base do
  before(:each) do
    site = Site.create! :source_name=> 'test', :base_url=> 'http://groupon.com'
    @base = Snapshooter::Crawler.new('test')
  end
  
  pending "a get request" do
    it "should accept full_path as an option and use the full url" do
      @base.should_receive(:open).with("#{@base.base_url}/deals")
      @base.get("#{@base.base_url}/deals", :full_path=> true)
    end
    
    it "should accept full_path as an option and use path only" do
      @base.should_receive(:open).with("#{@base.base_url}/deals")
      @base.get("/deals")
    end
  end
  
  context "parsing" do
    it "should process xpath on a document" do
      @base.stub(:doc).and_return(Nokogiri::HTML("<span id='foo'>rspec testing</span>"))
      @base.xpath("span[@id='foo']").first.text.should == 'rspec testing'
    end
  end     
  
  pending "split_address_telephone" do
    it "should separate raw_address and telephone" do
      @base.split_address_telephone("Sycamore 500 Valley Rd. WestDanville, California 222-831-3644").should eql(["Sycamore 500 Valley Rd. WestDanville, California ", "222-831-3644"])
    end

    it "should not affect ordinary numbers in address" do
      @base.split_address_telephone("Sycamore 500 Valley Rd. WestDanville, California 29087").should eql(["Sycamore 500 Valley Rd. WestDanville, California 29087", nil])
    end
  end
  
end
