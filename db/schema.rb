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

ActiveRecord::Schema.define(:version => 20110331104920) do

  create_table "deals", :force => true do |t|
    t.string   "name"
    t.string   "permalink"
    t.string   "deal_id"
    t.float    "sale_price"
    t.float    "actual_price"
    t.integer  "division_id"
    t.integer  "site_id"
    t.boolean  "active",                       :default => true
    t.boolean  "sold",                         :default => false
    t.integer  "hotness",                      :default => 0
    t.float    "lat",                          :default => 0.0
    t.float    "lng",                          :default => 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "expires_at"
    t.string   "raw_address"
    t.string   "telephone",      :limit => 30
    t.integer  "max_sold_count",               :default => 0
  end

  create_table "divisions", :force => true do |t|
    t.string   "name"
    t.string   "source"
    t.string   "url"
    t.integer  "site_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "division_id"
    t.string   "site_division_id"
  end

  create_table "geocodes", :force => true do |t|
    t.integer  "deal_id"
    t.float    "lat"
    t.float    "lng"
    t.string   "formatted_address"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mail_updates", :force => true do |t|
    t.string   "name"
    t.string   "email"
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
    t.integer  "site_id"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sold_since_last_snapshot_count"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                               :default => "", :null => false
    t.string   "encrypted_password",   :limit => 128, :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                       :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "type"
    t.string   "first_name"
    t.string   "last_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
