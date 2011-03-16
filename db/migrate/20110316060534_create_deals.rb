class CreateDeals < ActiveRecord::Migration
  def self.up
    create_table :deals do |t|
      t.string :name
      t.string :permalink
      t.string :deal_id
      t.decimal :sale_price
      t.decimal :actual_price
      t.integer :division_id
      t.integer :site_id
      t.boolean :active, :default => true
      t.boolean :sold, :default => false
      t.integer :hotness, :default => 0
      t.decimal :lat, :default => 0.0
      t.decimal :lng, :default => 0.0
      t.timestamps
    end
  end

  def self.down
    drop_table :deals
  end
end
