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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140501210509) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "days", force: :cascade do |t|
    t.integer "week_id"
    t.date    "date"
    t.index ["date"], name: "index_days_on_date", using: :btree
    t.index ["week_id"], name: "index_days_on_week_id", using: :btree
  end

  create_table "people", force: :cascade do |t|
    t.string   "name",                      limit: 50
    t.string   "login",                     limit: 20
    t.string   "phone",                     limit: 13
    t.string   "email",                     limit: 100
    t.string   "crypted_password",          limit: 40
    t.string   "salt",                      limit: 40
    t.string   "remember_token",            limit: 255
    t.datetime "remember_token_expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "postal_code"
    t.string   "location",                  limit: 30
    t.string   "address",                   limit: 50
    t.string   "phone2",                    limit: 13
    t.string   "preferences",               limit: 255
    t.boolean  "brevet",                                default: false, null: false
    t.index ["login"], name: "index_people_on_login", using: :btree
  end

  create_table "people_roles", id: false, force: :cascade do |t|
    t.integer  "person_id"
    t.integer  "role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["person_id", "role_id"], name: "index_people_roles_on_person_id_and_role_id", using: :btree
  end

  create_table "roles", force: :cascade do |t|
    t.string  "name",              limit: 40
    t.string  "authorizable_type", limit: 40
    t.integer "authorizable_id"
    t.index ["authorizable_id"], name: "index_roles_on_authorizable_id", using: :btree
  end

  create_table "saisons", force: :cascade do |t|
    t.date     "begin"
    t.date     "end"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name",       limit: 255
  end

  create_table "shiftinfos", force: :cascade do |t|
    t.string   "description", limit: 255
    t.time     "begin"
    t.time     "end"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "saison_id"
    t.time     "offset"
    t.index ["saison_id"], name: "index_shiftinfos_on_saison_id", using: :btree
  end

  create_table "shifts", force: :cascade do |t|
    t.integer  "day_id"
    t.integer  "shiftinfo_id"
    t.integer  "person_id"
    t.boolean  "enabled",      default: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["day_id", "shiftinfo_id"], name: "index_shifts_on_day_id_and_shiftinfo_id", using: :btree
    t.index ["shiftinfo_id"], name: "index_shifts_on_shiftinfo_id", using: :btree
  end

  create_table "weeks", force: :cascade do |t|
    t.integer  "number"
    t.integer  "person_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "enabled_saisons", limit: 3, default: ""
    t.index ["number"], name: "index_weeks_on_number", using: :btree
  end

end
