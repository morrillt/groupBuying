class AddStatsColumnsToSimpleGeoData < ActiveRecord::Migration
  def self.up
    add_column :simple_geo_data, :tomorrow_precipitation, :string
    add_column :simple_geo_data, :tomorrow_conditions, :string
    add_column :simple_geo_data, :tomorrow_min_temp, :string
    add_column :simple_geo_data, :tomorrow_max_temp, :string
    add_column :simple_geo_data, :tonight_precipitation, :string
    add_column :simple_geo_data, :tonigth_conditions, :string
    add_column :simple_geo_data, :tonigth_min_temp, :string
    add_column :simple_geo_data, :tonight_max_temp, :string
    add_column :simple_geo_data, :today_precipitation, :string
    add_column :simple_geo_data, :today_conditions, :string
    add_column :simple_geo_data, :today_min_temp, :string
    add_column :simple_geo_data, :today_max_temp, :string
    add_column :simple_geo_data, :conditions, :string
    add_column :simple_geo_data, :temperature, :string
    add_column :simple_geo_data, :wind_direction, :string
    add_column :simple_geo_data, :cloud_cover, :string
    add_column :simple_geo_data, :wind_speed, :string
    add_column :simple_geo_data, :dewpoint, :string
    add_column :simple_geo_data, :metro_score, :string
    add_column :simple_geo_data, :timestamp_sg, :string
  end

  def self.down
    remove_column :simple_geo_data, :tomorrow_precipitation
    remove_column :simple_geo_data, :tomorrow_conditions
    remove_column :simple_geo_data, :tomorrow_min_temp
    remove_column :simple_geo_data, :tomorrow_max_temp
    remove_column :simple_geo_data, :tonight_precipitation
    remove_column :simple_geo_data, :tonigth_conditions
    remove_column :simple_geo_data, :tonigth_min_temp
    remove_column :simple_geo_data, :tonight_max_temp
    remove_column :simple_geo_data, :today_precipitation
    remove_column :simple_geo_data, :today_conditions
    remove_column :simple_geo_data, :today_min_temp
    remove_column :simple_geo_data, :today_max_temp
    remove_column :simple_geo_data, :conditions
    remove_column :simple_geo_data, :temperature
    remove_column :simple_geo_data, :wind_direction
    remove_column :simple_geo_data, :cloud_cover
    remove_column :simple_geo_data, :wind_speed
    remove_column :simple_geo_data, :dewpoint
    remove_column :simple_geo_data, :metro_score
    remove_column :simple_geo_data, :timestamp_sg
  end
end
