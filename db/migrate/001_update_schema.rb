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
      t.integer     :hotness
      
      t.datetime    :start_on
      t.datetime    :end_on
      
      t.timestamps
    end
    
    create_table :snapshots do |t|
      t.belongs_to  :deal,            :null => false
      t.integer     :buyers_count,    :null => false
      t.boolean     :active,          :null => false
      t.datetime    :imported_at,     :null => false
    end
    
    create_table :snapshot_diffs do |t|
      t.belongs_to  :deal,                :null => false
      t.integer     :start_snapshot_id,   :null => false
      t.integer     :end_snapshot_id,     :null => false
      t.integer     :buyer_change,        :null => false
      t.integer     :revenue_change,      :null => false
      t.boolean     :closed,              :null => false
      t.datetime    :changed_at,          :null => false
    end
    
    create_table :sites do |t|
      t.string :name, :null => false
      t.datetime :created_at
      t.datetime :updated_at


      t.timestamps
    end

    create_table :opentable do |t|
      t.string  :deal_id,   :limit => 200,                    :null => false
      t.text    :title,                                      :null => false
      t.string  :pricetext, :limit => 200,                    :null => false
      t.string  :valuetext, :limit => 200,                    :null => false
      t.string  :count,     :limit => 200,                    :null => false
      t.date    :datetext,                                    :null => false
      t.string  :location,  :limit => 200,                    :null => false
      t.date    :datadate,                                    :null => false
      t.binary  :status,    :limit => 1,                      :null => false
      t.time    :time,                                        :null => false
      t.string :deal_id, :limit => 200, :null=>false
      t.text :title, :null=> false

      t.timestamps

    end

    create_table :travelzoo, :force => true do |t|
      t.string  :deal_id,   :limit => 200,                    :null => false
      t.text    :title,                                       :null => false
      t.string  :pricetext, :limit => 200,                    :null => false
      t.string  :valuetext, :limit => 200,                    :null => false
      t.string  :count,     :limit => 200,                    :null => false
      t.date    :datetext,                                    :null => false
      t.string  :location,  :limit => 200,                    :null => false
      t.date    :datadate,                                    :null => false
      t.binary  :status,    :limit => 1,                      :null => false
      t.time    :time,                                        :null => false

      t.timestamps
    end

    create_table :travelzoouk, :force => true do |t|
      t.string  :deal_id,   :limit => 200,                    :null => false
      t.text    :title,                                       :null => false
      t.string  :pricetext, :limit => 200,                    :null => false
      t.string  :valuetext, :limit => 200,                    :null => false
      t.string  :count,     :limit => 200,                    :null => false
      t.date    :datetext,                                    :null => false
      t.string  :location,  :limit => 200,                    :null => false
      t.date    :datadate,                                    :null => false
      t.binary  :status,    :limit => 1,                      :null => false
      t.time    :time,                                        :null => false

      t.timestamps
    end

    create_table :groupon do |t|
      t.string :deal_id, :null => false
      t.text   :title, :null => false
      t.string :pricetext, :null => false
      t.string :valuetext, :null => false
      t.string :count
      t.string :datetext
      t.string :location
      t.date :datadate
      t.text :urltext
      t.binary :status
      t.time :time
      t.integer :hotindex

      t.timestamps
    end
    
    %w(Groupon OpenTable TravelZoo TravelZooUk).each do |old_table|
      Site.create(:name => old_table.underscore)
      add_column old_table.downcase, :converted, :boolean, :null => false, :default => false
    end
    
    add_index :deals, [:site_id, :slug, :zip_code]
  end
  
  def self.down
    [:deals, :snapshots, :sites, :groupon].each{ |tbl| drop_table tbl }
  end
end
