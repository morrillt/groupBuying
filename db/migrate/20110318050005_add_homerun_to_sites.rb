class AddHomerunToSites < ActiveRecord::Migration
  def self.up
    Site.create(:name => "Homerun", :base_url => "http://www.homerun.com", :source_name => "homerun", :active => true)
  end

  def self.down
    Site.find_by_source_name("homerun").try(:destroy)
  end
end
