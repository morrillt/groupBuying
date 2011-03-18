class AddTravelZoo < ActiveRecord::Migration
  def self.up
    Site.create(:name => 'Travel Zoo', :base_url => 'http://www.travelzoo.com', :active => true, :source_name => "travel_zoo")
  end

  def self.down
    if site = Site.find_by_source_name('travel_zoo')
      site.destroy
    end
  end
end
