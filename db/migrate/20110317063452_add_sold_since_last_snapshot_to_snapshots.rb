class AddSoldSinceLastSnapshotToSnapshots < ActiveRecord::Migration
  def self.up
    add_column :snapshots, :sold_since_last_snapshot_count, :integer
  end

  def self.down
    remove_column :snapshots, :sold_since_last_snapshot_count
  end
end
