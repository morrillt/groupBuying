class AddDealsTelephoneField < ActiveRecord::Migration
  def self.up
    add_column :deals, :telephone, :string, :limit => 30
  end

  def self.down
    remove_column :deals, :telephone
  end
end
