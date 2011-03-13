class AddDivisions < ActiveRecord::Migration
  def self.up
    rename_column :deals, :slug, :deal_id
    add_column    :sites, :active, :boolean, :null => false, :default => true
    add_column    :deals, :division_id, :integer
    
    create_table :divisions do |t|
      t.belongs_to  :site,              :null => false
      t.string      :name,              :null => false
      t.string      :url_part
      t.string      :division_id
      t.datetime    :last_checked_at,   :default => "2000-01-01".to_date
    
      t.timestamps
    end
  end
  
  def self.down
    rename_column :deals, :deal_id, :slug
    
    remove_column :deals, :division_id
    remove_column :sites, :active
    
    drop_table :divisions
  end
end