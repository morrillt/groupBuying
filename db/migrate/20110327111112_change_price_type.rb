class ChangePriceType < ActiveRecord::Migration
  def self.up
    change_column :deals, :sale_price, :float
    change_column :deals, :actual_price, :float
  end

  def self.down
    change_column :deals, :actual_price, :decimal
    change_column :deals, :sale_price, :decimal
  end
end