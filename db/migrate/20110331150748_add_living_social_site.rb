class AddLivingSocialSite < ActiveRecord::Migration
  def self.up
    Site.create(:name => 'Living Social', :base_url => 'http://livingsocial.com', :active => true, :source_name => "living_social")
  end

  def self.down
    Site.find_by_source_name("living_social").destroy    
  end
end
