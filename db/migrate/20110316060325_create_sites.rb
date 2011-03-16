class CreateSites < ActiveRecord::Migration
  def self.up
    create_table :sites do |t|
      t.string :name
      t.string :base_url
      t.string :source_name
      t.boolean :active

      t.timestamps
    end
    
    Site.create(:name => 'Kgb Deals', :base_url => 'http://www.kgbdeals.com', :active => true, :source_name => "kgb_deals")
  end

  def self.down
    drop_table :sites
  end
end
