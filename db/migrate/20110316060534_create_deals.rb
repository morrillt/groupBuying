class CreateDeals < ActiveRecord::Migration
  def self.up
    create_table :deals do |t|
      t.string :name
      t.string :permalink
      t.string :token
      t.decimal :price
      t.integer :division_id
      t.integer :site_id
      t.boolean :active, :default => true
      t.boolean :sold, :default => false

      t.timestamps
    end
  end

  def self.down
    drop_table :deals
  end
end
