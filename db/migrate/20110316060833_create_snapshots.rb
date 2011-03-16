class CreateSnapshots < ActiveRecord::Migration
  def self.up
    create_table :snapshots do |t|
      t.string :deal_id
      t.integer :sold_count
      t.integer :site_id
      t.timestamps
    end
  end

  def self.down
    drop_table :snapshots
  end
end
