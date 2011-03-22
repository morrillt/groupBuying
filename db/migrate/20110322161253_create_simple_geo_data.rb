class CreateSimpleGeoData < ActiveRecord::Migration
  def self.up
    create_table :simple_geo_data do |t|
      t.integer :deal_id
      t.string :category
      t.string :weather
      t.integer :population
      t.string :timezone
      t.string :census_data

      t.timestamps
    end
  end

  def self.down
    drop_table :simple_geo_data
  end
end
