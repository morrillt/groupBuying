class AddDealsZipcodeField < ActiveRecord::Migration
  def self.up   
    add_column :deals, :zipcode, :integer
  end

  def self.down
    remove_column :deals, :zipcode
  end
end