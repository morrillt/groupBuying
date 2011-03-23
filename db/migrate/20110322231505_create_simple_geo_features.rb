class CreateSimpleGeoFeatures < ActiveRecord::Migration
  def self.up
    create_table :simple_geo_features do |t|
      t.integer :simple_geo_data_id
      t.string :handle
      t.decimal :initial_lat_bound
      t.decimal :initial_long_bound
      t.decimal :final_lat_bound
      t.decimal :final_long_bound
      t.string :type
      t.string :category
      t.string :subcategory
      t.string :abbr
      t.string :name
      t.string :license
      t.string :link

      t.timestamps
      execute "ALTER TABLE simple_geo_features 
      ADD CONSTRAINT fk_simple_geo_id 
      FOREIGN KEY (simple_geo_data_id) REFERENCE
      simple_geo_data(id)"
    end
  end

  def self.down
    drop_table :simple_geo_features
  end
end
