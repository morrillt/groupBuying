class ChartSpeedup < ActiveRecord::Migration
  def self.up
    add_column :snapshot_diffs, :site_id,     :integer
    add_column :snapshot_diffs, :division_id, :integer
  end
  
  def self.down
    remove_column :snapshot_diffs, :site_id
    remove_column :snapshot_diffs, :division_id
  end
end