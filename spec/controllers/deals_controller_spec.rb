require 'spec_helper'

describe DealsController do
  
  it "should render the index page given a site" do
    get :index, :site_id => Factory(:site).id
    response.should be_success
  end
  
  it "should render 404 given no site id" do
    get :index
    response.code.to_i.should == 404
  end  
end