class AddImporter < ActiveRecord::Migration
  def self.up
    add_column :sites, :importer_class, :string
  end
  
  def self.down
    remove_column :sites, :importer_class
  end
end