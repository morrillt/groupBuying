class CreateDeals < ActiveRecord::Migration
  def self.up
    create_table :deals do |t|
      t.string :name
      t.string :permalink
<<<<<<< HEAD
      t.string :deal_id
      t.decimal :sale_price
      t.decimal :actual_price
=======
      t.string :token
      t.decimal :price
>>>>>>> 62992eb1545a85afc81867a39aecdb29e85392c0
      t.integer :division_id
      t.integer :site_id
      t.boolean :active, :default => true
      t.boolean :sold, :default => false
<<<<<<< HEAD
      t.integer :hotness, :default => 0
      t.decimal :lat, :default => 0.0
      t.decimal :lng, :default => 0.0
=======

>>>>>>> 62992eb1545a85afc81867a39aecdb29e85392c0
      t.timestamps
    end
  end

  def self.down
    drop_table :deals
  end
end
