require 'spec_helper'
                      
module Snapshooter
  describe Base do
    before(:each) do
      @site = Site.create :name=> 'test', :source_name=> 'test', :base_url=> 'http://test.com', :active=>true
      @base = Base.new('some_crawler')
    end

    after(:each) do
      Site.delete(@site.id)
    end
  
    it "should have REGEX constants" do
      Base.constants.should include('TELEPHONE_REGEX')
      Base.constants.should include('UK_TELEPHONE_REGEX')
      Base.constants.should include('PRICE_REGEX')
    end                                         
    
    it "mechanize should return Mechanize object" do
      @base.doc.should be_kind_of Mechanize
    end                                              
      
    it "should get web-page with Mechanize" do
      
    end
    
    it "should detect_absolute_path with true for full urls" do
      options = {}
      @base.detect_absolute_path('http://google.com', options)
      options[:full_path].should be_true
    end

    it "should detect_absolute_path with false for relative urls" do
      options = {}
      @base.detect_absolute_path('/cities', options)
      options[:full_path].should be_false
    end   
    
    context "split_address_telephone" do
      it "should separate raw_address and telephone" do
        Base.split_address_telephone("Sycamore 500 Valley Rd. WestDanville, California 222-831-3644").should eql(["Sycamore 500 Valley Rd. WestDanville, California ", "222-831-3644"])
      end

      it "should not affect ordinary numbers in address" do
        Base.split_address_telephone("Sycamore 500 Valley Rd. WestDanville, California 29087").should eql(["Sycamore 500 Valley Rd. WestDanville, California 29087", nil])
      end
    end
    
    context "time_counter" do
      it "should parse short time_counter and return expire time" do 
        time_counter = {'d' => 3, 'h' => 2, 'm' => 30}
        expires_at = Base.time_counter_to_expires_at(time_counter)
        now = Time.now
        expires_at.day.should == (now + 3.days).day
        expires_at.hour.should == (now + 2.hours).hour
        expires_at.min.should == (now + 30.minutes).min
      end
    end

  end
end
