class AddCurrentSnap < ActiveRecord::Migration
  def self.up
    add_column :deals, :current_snapshot_id, :string
  end
  
  def self.down
    remove_column :deals, :current_snapshot_id, :string
  end
end