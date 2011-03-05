class UpdateAgain < ActiveRecord::Migration
  def self.up
    add_column  :deals, :buyers_count, :integer
  end
  
  def self.down
    remove_column  :deals, :buyers_count
  end
end