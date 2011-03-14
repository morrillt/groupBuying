class CacheDealRevenue < ActiveRecord::Migration
  def self.up
    add_column :deals, :revenue, :integer
  end
  
  def self.down
    remove_column :deals, :revenue, :integer
  end
end