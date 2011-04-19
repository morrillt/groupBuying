class AddWeforiaSiteCrawler < ActiveRecord::Migration
  def self.up
    Site.create(:name => 'Weforia', :base_url => 'http://www.weforia.com', :active => true, :source_name => "weforia")
  end

  def self.down
    if site = Site.find_by_source_name('weforia')
      site.destroy
    end
  end
end
