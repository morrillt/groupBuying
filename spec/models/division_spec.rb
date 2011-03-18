require 'spec_helper'

describe Division do
  before(:each) do
    @division = Factory(:division)
  end
  
  it { should belong_to(:site) }
  it { should have_many(:deals) }
  it { should validate_uniqueness_of(:name) }
end