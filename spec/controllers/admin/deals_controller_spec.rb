require 'spec_helper'

describe Admin::DealsController do
  
  it "should render the index action" do
    get :index
    response.should be_success
  end
  
  it "should render the show action" do
    deal = Factory(:deal)
    get :show, :id => deal.id
    response.should be_success
  end
end