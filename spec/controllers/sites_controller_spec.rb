require 'spec_helper'

describe SitesController do
  before :each do
    @site = Factory(:site)
  end
  
  it "should render the index action" do
    Chart.should_receive(:new)
    Site.should_receive(:active)
    Chart.should_receive(:hourly_revenue_by_site)
    get :index
  end
  
  it "should render the show action" do
    Site.should_receive(:find_by_source_name).with(@site.source_name).and_return(@site)
    Deal.should_receive(:get_info).with(@site).and_return({})
    Chart.should_receive(:hourly_revenue_by_divisions).with(@site.id)
    
    get :show, :id => @site.source_name
  end
  
  it "should render the coupon count as json" do
    Site.should_receive(:coupons_purchased_to_date).and_return(25)
    get :coupons_count, :format => :json
    JSON.parse(response.body)["coupons_count"].should == 25
  end
end