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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150712140719) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"
  enable_extension "hstore"

  create_table "customers", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.text     "access_token"
    t.text     "braintree_id"
    t.text     "instagram_id"
    t.text     "instagram_profile_picture"
    t.text     "email"
    t.text     "instagram_username"
    t.datetime "signup_began_at"
    t.text     "timezone"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "events", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.uuid     "visitor_id"
    t.text     "action"
    t.text     "app_version"
    t.text     "ip"
    t.text     "referrer"
    t.text     "path"
    t.text     "user_agent"
    t.hstore   "parameters",  default: {}, null: false
    t.datetime "created_at",               null: false
  end

  add_index "events", ["parameters"], name: "index_events_on_parameters", using: :gin
  add_index "events", ["visitor_id"], name: "index_events_on_visitor_id", using: :btree

  create_table "signups", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.text     "instagram_id"
    t.text     "instagram_username"
    t.text     "instagram_profile_picture"
    t.text     "email"
    t.text     "access_token"
    t.text     "timezone"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.text     "payment_method_nonce"
  end

  add_index "signups", ["instagram_id"], name: "index_signups_on_instagram_id", using: :btree

  create_table "visitors", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.text     "ip"
    t.text     "referrer"
    t.text     "path"
    t.text     "user_agent"
    t.hstore   "parameters", default: {}, null: false
    t.datetime "created_at",              null: false
  end

  add_index "visitors", ["parameters"], name: "index_visitors_on_parameters", using: :gin

  add_foreign_key "events", "visitors"
end
