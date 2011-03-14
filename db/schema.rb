# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 8) do

  create_table "deals", :force => true do |t|
    t.string   "title",                                  :null => false
    t.string   "url"
    t.string   "deal_id",                                :null => false
    t.integer  "site_id",                                :null => false
    t.boolean  "active",              :default => false, :null => false
    t.integer  "price",                                  :null => false
    t.integer  "original_price"
    t.string   "currency"
    t.integer  "buyers_count"
    t.integer  "hotness"
    t.datetime "start_on"
    t.datetime "end_on"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "division_id"
    t.string   "status",                                 :null => false
    t.datetime "expires_at"
    t.float    "latitude"
    t.float    "longitude"
    t.string   "current_snapshot_id"
    t.integer  "revenue"
  end

  add_index "deals", ["site_id", "deal_id"], :name => "index_deals_on_site_id_and_slug_and_zip_code"

  create_table "divisions", :force => true do |t|
    t.integer  "site_id",                                            :null => false
    t.string   "name",                                               :null => false
    t.string   "url_part"
    t.string   "division_id"
    t.datetime "last_checked_at", :default => '2000-01-01 00:00:00'
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "groupon", :force => true do |t|
    t.string   "deal_id",                       :null => false
    t.text     "title",                         :null => false
    t.string   "pricetext",                     :null => false
    t.string   "valuetext",                     :null => false
    t.string   "count"
    t.string   "datetext"
    t.string   "location"
    t.date     "datadate"
    t.text     "urltext"
    t.binary   "status"
    t.time     "time"
    t.integer  "hotindex"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "converted",  :default => false, :null => false
  end

  create_table "opentable", :force => true do |t|
    t.string   "deal_id",    :limit => 200,                    :null => false
    t.text     "title",                                        :null => false
    t.string   "pricetext",  :limit => 200,                    :null => false
    t.string   "valuetext",  :limit => 200,                    :null => false
    t.string   "count",      :limit => 200,                    :null => false
    t.date     "datetext",                                     :null => false
    t.string   "location",   :limit => 200,                    :null => false
    t.date     "datadate",                                     :null => false
    t.binary   "status",     :limit => 255,                    :null => false
    t.time     "time",                                         :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "converted",                 :default => false, :null => false
  end

  create_table "sites", :force => true do |t|
    t.string   "name",                             :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "active",         :default => true, :null => false
    t.string   "importer_class"
  end

  create_table "snapshot_diffs", :force => true do |t|
    t.integer  "deal_id",         :null => false
    t.integer  "buyer_change",    :null => false
    t.integer  "revenue_change",  :null => false
    t.boolean  "closed",          :null => false
    t.datetime "changed_at",      :null => false
    t.string   "snapshot_id",     :null => false
    t.string   "old_snapshot_id"
    t.integer  "site_id"
    t.integer  "division_id"
  end

  add_index "snapshot_diffs", ["changed_at", "deal_id"], :name => "created_and_deal_index"

  create_table "snapshots", :force => true do |t|
    t.integer  "deal_id",      :null => false
    t.integer  "buyers_count", :null => false
    t.boolean  "active",       :null => false
    t.datetime "imported_at",  :null => false
  end

  create_table "travelzoo", :force => true do |t|
    t.string   "deal_id",    :limit => 200,                    :null => false
    t.text     "title",                                        :null => false
    t.string   "pricetext",  :limit => 200,                    :null => false
    t.string   "valuetext",  :limit => 200,                    :null => false
    t.string   "count",      :limit => 200,                    :null => false
    t.date     "datetext",                                     :null => false
    t.string   "location",   :limit => 200,                    :null => false
    t.date     "datadate",                                     :null => false
    t.binary   "status",     :limit => 255,                    :null => false
    t.time     "time",                                         :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "converted",                 :default => false, :null => false
  end

  create_table "travelzoouk", :force => true do |t|
    t.string   "deal_id",    :limit => 200,                    :null => false
    t.text     "title",                                        :null => false
    t.string   "pricetext",  :limit => 200,                    :null => false
    t.string   "valuetext",  :limit => 200,                    :null => false
    t.string   "count",      :limit => 200,                    :null => false
    t.date     "datetext",                                     :null => false
    t.string   "location",   :limit => 200,                    :null => false
    t.date     "datadate",                                     :null => false
    t.binary   "status",     :limit => 255,                    :null => false
    t.time     "time",                                         :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "converted",                 :default => false, :null => false
  end

end
