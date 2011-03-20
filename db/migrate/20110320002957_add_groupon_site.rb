class AddGrouponSite < ActiveRecord::Migration
  def self.up
    add_column :divisions, :division_id, :integer
    groupon = Site.create(:name => 'Groupon', :source_name => 'groupon', :base_url => 'http://www.groupon.com/', :active => true)
    Groupon.divisions.each do |division|
      groupon.divisions.create(:name => division.name, :division_id => division.id, :url => groupon.base_url + division.id, :source => 'groupon')
    end
  end

  def self.down
    if site = Site.find_by_source_name('groupon')
      site.divisions.map(&:destroy)
      site.destroy
    end
    remove_column :divisions, :division_id
  end
end
