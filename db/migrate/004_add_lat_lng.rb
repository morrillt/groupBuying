class AddLatLng < ActiveRecord::Migration
  def self.up
    remove_column :deals, :zip_code
    rename_column :deals, :value, :original_price
    
    add_column  :deals, :status,      :string,   :null => false
    add_column  :deals, :expires_at,  :datetime
    add_column  :deals, :latitude,    :float
    add_column  :deals, :longitude,   :float
    
    remove_column :snapshot_diffs, :start_snapshot_id
    remove_column :snapshot_diffs, :end_snapshot_id
    
    add_column :snapshot_diffs, :snapshot_id, :string, :null => false
    add_column :snapshot_diffs, :old_snapshot_id, :string
  end
  
  def self.down
    add_column :deals, :zip_code, :string, :null => false
    rename_column :deals, :original_price, :value
    
    remove_column :deals, :status
    remove_column :deals, :expires_at
    remove_column :deals, :latitude
    remove_column :deals, :longitude
  end
end