require 'spec_helper'

describe Admin::DivisionsController do
  
  it "should render the index action" do
    get :index
    response.should be_success
  end
  
  it "should render the show action" do
    division = Factory(:division)
    get :show, :id => division.id
    response.should be_success
  end
end