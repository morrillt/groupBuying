class UpdateSchema < ActiveRecord::Migration
  def self.up
    create_table :deals do |t|
      t.string      :title,         :null => false
      t.string      :url#,           :null => false
      t.string      :slug,          :null => false
      t.belongs_to  :site,          :null => false
      t.string      :zip_code,      :null => false
      t.boolean     :active,        :null => false, :default => false
      t.integer     :price,         :null => false
      t.integer     :value#,         :null => false
      t.string      :currency#,      :null => false
      t.integer     :buyers_count
      
      t.timestamps
    end
    
    create_table :snapshots do |t|
      t.belongs_to  :deal,            :null => false
      t.boolean     :current,         :null => false, :default => false
      t.integer     :buyers,          :null => false
      t.date        :data_date,       :null => false
      t.time        :data_time,       :null => false
    end
    
    create_table :sites do |t|
      t.string :name, :null => false
      
      t.timestamps
    end
    
    %w(Groupon OpenTable TravelZoo TravelZooUk).each do |old_table|
      Site.create(:name => old_table.underscore)
      add_column old_table.downcase, :converted, :boolean, :null => false, :default => false
    end
    
    add_index :deals, [:site_id, :slug, :zip_code]
  end
  
  def self.down
    [:deals, :snapshots, :sites].each{ |tbl| drop_table tbl }
  end
end