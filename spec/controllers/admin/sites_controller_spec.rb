require 'spec_helper'

describe Admin::SitesController do
  
  it "should render the index action" do
    get :index
    response.should be_success
  end
  
  it "should render the show action" do
    site = Factory(:site)
    get :show, :id => site.id
    response.should be_success
  end
end