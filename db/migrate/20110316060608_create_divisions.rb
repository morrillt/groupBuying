class CreateDivisions < ActiveRecord::Migration
  def self.up
    create_table :divisions do |t|
      t.string :name
      t.string :source
<<<<<<< HEAD
      t.string :url
      t.integer :site_id
=======

>>>>>>> 62992eb1545a85afc81867a39aecdb29e85392c0
      t.timestamps
    end
  end

  def self.down
    drop_table :divisions
  end
end
