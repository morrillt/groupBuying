require 'spec_helper'

describe Snapshooter::Base do
  before(:each) do
    @base = Snapshooter::Base.new
    @base.stub(:base_url).and_return("http://groupon.com")
  end
  
  context "a get request" do
    it "should accept full_path as an option and use the full url" do
      @base.should_receive(:open).with("#{@base.base_url}/deals")
      @base.get("#{@base.base_url}/deals", :full_path => true)
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
  
end