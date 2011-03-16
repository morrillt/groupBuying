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
    t.string   "token"
    t.decimal  "price"
    t.integer  "division_id"
    t.integer  "site_id"
    t.boolean  "active",      :default => true
    t.boolean  "sold",        :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "divisions", :force => true do |t|
    t.string   "name"
    t.string   "source"
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
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
