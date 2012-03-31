# encoding: UTF-8
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

ActiveRecord::Schema.define(:version => 20120331002609) do

  create_table "days", :force => true do |t|
    t.integer "week_id"
    t.date    "date"
  end

  add_index "days", ["date"], :name => "index_days_on_date"
  add_index "days", ["week_id"], :name => "index_days_on_week_id"

  create_table "people", :force => true do |t|
    t.string   "name",                      :limit => 50
    t.string   "login",                     :limit => 20
    t.string   "phone",                     :limit => 13
    t.string   "email",                     :limit => 100
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "postal_code"
    t.string   "location",                  :limit => 30
    t.string   "address",                   :limit => 50
    t.string   "phone2",                    :limit => 13
    t.string   "preferences"
  end

  add_index "people", ["login"], :name => "index_people_on_login"

  create_table "people_roles", :id => false, :force => true do |t|
    t.integer  "person_id"
    t.integer  "role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "people_roles", ["person_id", "role_id"], :name => "index_people_roles_on_person_id_and_role_id"

  create_table "roles", :force => true do |t|
    t.string  "name",              :limit => 40
    t.string  "authorizable_type", :limit => 40
    t.integer "authorizable_id"
  end

  add_index "roles", ["authorizable_id"], :name => "index_roles_on_authorizable_id"

  create_table "saisons", :force => true do |t|
    t.date     "begin"
    t.date     "end"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
  end

  create_table "shiftinfos", :force => true do |t|
    t.string   "description"
    t.time     "begin"
    t.time     "end"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "saison_id"
  end

  add_index "shiftinfos", ["saison_id"], :name => "index_shiftinfos_on_saison_id"

  create_table "shifts", :force => true do |t|
    t.integer  "day_id"
    t.integer  "shiftinfo_id"
    t.integer  "person_id"
    t.boolean  "enabled",      :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "shifts", ["day_id", "shiftinfo_id"], :name => "index_shifts_on_day_id_and_shiftinfo_id"
  add_index "shifts", ["shiftinfo_id"], :name => "index_shifts_on_shiftinfo_id"

  create_table "weeks", :force => true do |t|
    t.integer  "number"
    t.integer  "person_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "enabled_saisons", :limit => 3, :default => ""
  end

  add_index "weeks", ["number"], :name => "index_weeks_on_number"

end
