class AddDealMaxSaleCount < ActiveRecord::Migration
  def self.up
    add_column :deals, :max_sold_count, :integer, :default => 0
  end

  def self.down
    remove_column :deals, :max_sold_count
  end
end