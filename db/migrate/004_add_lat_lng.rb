class AddLatLng < ActiveRecord::Migration
  def self.up
    remove_column :deals, :zip_code
    
    add_column  :deals, :status,      :string,   :null => false
    add_column  :deals, :expires_at,  :datetime
    add_column  :deals, :latitude,    :float
    add_column  :deals, :longitude,   :float
  end
  
  def self.down
    #add_column :deals, :zip_code, :string, :null => false
    
    remove_column :deals, :status
    remove_column :deals, :expires_at
    remove_column :deals, :latitude
    remove_column :deals, :longitude
  end
end