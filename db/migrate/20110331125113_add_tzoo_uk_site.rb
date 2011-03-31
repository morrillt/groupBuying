class AddTzooUkSite < ActiveRecord::Migration
  def self.up
    Site.create(:name => 'Travel Zoo UK', :base_url => 'http://www.travelzoo.com/uk', :active => true, :source_name => "travel_zoo_uk")
  end

  def self.down
    Site.find_by_source_name("travel_zoo_uk").destroy    
  end
end
