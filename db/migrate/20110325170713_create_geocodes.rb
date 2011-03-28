class CreateGeocodes < ActiveRecord::Migration
  def self.up
    create_table :geocodes do |t|
      t.integer :deal_id
      t.float :lat
      t.float :lng
      t.string :formatted_address

      t.timestamps
    end
  end

  def self.down
    drop_table :geocodes
  end
end
