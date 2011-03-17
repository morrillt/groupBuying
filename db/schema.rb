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

ActiveRecord::Schema.define(:version => 20110316060833) do

  create_table "deals", :force => true do |t|
    t.string   "name"
    t.string   "permalink"
<<<<<<< HEAD
    t.string   "deal_id"
    t.decimal  "sale_price",   :precision => 10, :scale => 0
    t.decimal  "actual_price", :precision => 10, :scale => 0
    t.integer  "division_id"
    t.integer  "site_id"
    t.boolean  "active",                                      :default => true
    t.boolean  "sold",                                        :default => false
    t.integer  "hotness",                                     :default => 0
    t.decimal  "lat",          :precision => 10, :scale => 0, :default => 0
    t.decimal  "lng",          :precision => 10, :scale => 0, :default => 0
=======
    t.string   "token"
    t.decimal  "price"
    t.integer  "division_id"
    t.integer  "site_id"
    t.boolean  "active",      :default => true
    t.boolean  "sold",        :default => false
>>>>>>> 62992eb1545a85afc81867a39aecdb29e85392c0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "divisions", :force => true do |t|
    t.string   "name"
    t.string   "source"
<<<<<<< HEAD
    t.string   "url"
    t.integer  "site_id"
=======
>>>>>>> 62992eb1545a85afc81867a39aecdb29e85392c0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sites", :force => true do |t|
    t.string   "name"
    t.string   "base_url"
    t.string   "source_name"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "snapshots", :force => true do |t|
    t.string   "deal_id"
    t.integer  "sold_count"
<<<<<<< HEAD
    t.integer  "site_id"
=======
>>>>>>> 62992eb1545a85afc81867a39aecdb29e85392c0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
