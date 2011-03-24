class CreateHourlyRevenueBySites < ActiveRecord::Migration
  def self.up
    create_table :hourly_revenue_by_sites do |t|
      t.integer :site_id
      t.integer :order
      t.integer :revenue

      t.timestamps
    end
  end

  def self.down
    drop_table :hourly_revenue_by_sites
  end
end
