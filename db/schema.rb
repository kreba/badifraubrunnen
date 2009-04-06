# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20084) do

  create_table "days", :force => true do |t|
    t.integer "week_id"
    t.date    "date"
  end

  create_table "people", :force => true do |t|
    t.string   "login",                     :limit => 20
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.string   "name",                      :limit => 50
    t.string   "email",                     :limit => 100
    t.string   "phone",                     :limit => 13
    t.string   "phone2",                    :limit => 13
    t.string   "address",                   :limit => 50
    t.integer  "postal_code"
    t.string   "location",                  :limit => 30
    t.string   "preferences"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "people_roles", :id => false, :force => true do |t|
    t.integer  "person_id"
    t.integer  "role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", :force => true do |t|
    t.string  "name",              :limit => 40
    t.string  "authorizable_type", :limit => 40
    t.integer "authorizable_id"
  end

  create_table "shiftinfos", :force => true do |t|
    t.string   "description"
    t.time     "begin"
    t.time     "end"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "saison_id"
  end

  create_table "shifts", :force => true do |t|
    t.integer  "day_id"
    t.integer  "shiftinfo_id"
    t.integer  "person_id"
    t.boolean  "enabled",      :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "weeks", :force => true do |t|
    t.integer  "number"
    t.integer  "person_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
