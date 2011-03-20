class AddOpenTable < ActiveRecord::Migration
  def self.up
    site = Site.create(:name => "Open Table", :source_name => 'open_table', :base_url => 'http://spotlight.opentable.com/deal')
    
    # create divisions
    %w(atlanta boston chicago denver los-angeles minneapolis-st-paul 
    new-york philadelphia san-francisco washington-dc).each do |division_name|
      site.divisions.create(:source => 'open_table', :url => "/#{division_name}", :name => division_name)
    end
  end

  def self.down
    if site = Site.find_by_source_name("open_table")
      site.destroy
    end
  end
end
