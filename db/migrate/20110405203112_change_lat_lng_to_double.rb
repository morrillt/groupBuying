class ChangeLatLngToDouble < ActiveRecord::Migration
  def self.up
    change_column :deals, :lat, :double
    change_column :deals, :lng, :double
  end

  def self.down
    change_column :deals, :lat, :float
    change_column :deals, :lng, :float
  end
end