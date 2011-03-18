class AddExpiresAtToDeals < ActiveRecord::Migration
  def self.up
    add_column :deals, :expires_at, :datetime
    add_column :deals, :raw_address, :string
  end

  def self.down
    remove_column :deals, :expires_at
    remove_column :deals, :raw_address
  end
end
