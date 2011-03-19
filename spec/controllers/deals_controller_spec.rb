require 'spec_helper'

describe DealsController do
  
  it "should export the deals" do
    get(:export)
    response.should be_success
  end
end