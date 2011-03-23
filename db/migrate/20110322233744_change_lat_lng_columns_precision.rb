class ChangeLatLngColumnsPrecision < ActiveRecord::Migration
  def self.up
    change_column(:deals, :lat, Float, :precision => 30)
    change_column(:deals, :lng, Float, :precision => 30)
  end

  def self.down
    change_column(:deals, :lat, :decimal)
    change_column(:deals, :lng, :decimal)
  end
end
