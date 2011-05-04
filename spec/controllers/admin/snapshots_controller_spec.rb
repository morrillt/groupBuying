require 'spec_helper'

describe Admin::SnapshotsController do
  
  before(:each) do
    credentials = ActionController::HttpAuthentication::Basic.encode_credentials 'admin', 'GBin2011'
    request.env['HTTP_AUTHORIZATION'] = credentials
  end

  it "should render the index action" do
    get :index
    response.should be_success
  end
  
  it "should render the show action" do
    snapshot = Factory(:snapshot)
    get :show, :id => snapshot.id
    response.should be_success
  end
end
