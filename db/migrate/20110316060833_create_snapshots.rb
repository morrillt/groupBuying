class CreateSnapshots < ActiveRecord::Migration
  def self.up
    create_table :snapshots do |t|
      t.string :deal_id
      t.integer :sold_count
<<<<<<< HEAD
      t.integer :site_id
=======

>>>>>>> 62992eb1545a85afc81867a39aecdb29e85392c0
      t.timestamps
    end
  end

  def self.down
    drop_table :snapshots
  end
end
