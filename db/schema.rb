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

ActiveRecord::Schema.define(version: 20150721005505) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"
  enable_extension "hstore"

  create_table "customer_sessions", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.uuid     "customer_id"
    t.uuid     "visitor_id"
    t.datetime "last_accessed_at"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  create_table "customers", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.text     "braintree_id"
    t.text     "instagram_id"
    t.text     "instagram_profile_picture"
    t.text     "instagram_username"
    t.datetime "signup_began_at"
    t.text     "timezone"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.text     "instagram_full_name"
    t.text     "website"
    t.integer  "instagram_follows_count"
    t.integer  "instagram_followed_by_count"
    t.integer  "instagram_media_count"
    t.uuid     "signup_id"
    t.datetime "profile_created_at"
    t.text     "access_token"
    t.text     "access_token_key"
    t.text     "access_token_iv"
    t.text     "email"
    t.text     "email_key"
    t.text     "email_iv"
    t.datetime "first_posted_at"
  end

  add_index "customers", ["signup_id"], name: "index_customers_on_signup_id", using: :btree

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
    t.uuid     "customer_id"
  end

  add_index "events", ["customer_id"], name: "index_events_on_customer_id", using: :btree
  add_index "events", ["parameters"], name: "index_events_on_parameters", using: :gin
  add_index "events", ["visitor_id"], name: "index_events_on_visitor_id", using: :btree

  create_table "instagram_session_logs", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.uuid     "instagram_session_id"
    t.integer  "response_time"
    t.string   "endpoint"
    t.text     "params"
    t.integer  "status"
    t.datetime "created_at"
  end

  add_index "instagram_session_logs", ["instagram_session_id"], name: "index_instagram_session_logs_on_instagram_session_id", using: :btree

  create_table "instagram_sessions", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.text     "access_token"
    t.text     "access_token_key"
    t.text     "access_token_iv"
    t.datetime "finished_at"
    t.datetime "created_at"
    t.string   "error"
    t.text     "backtrace"
    t.integer  "milliseconds_to_finish"
  end

  create_table "plans", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.text     "name"
    t.text     "slug"
    t.integer  "duration"
    t.integer  "amount_cents"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "plans", ["slug"], name: "index_plans_on_slug", unique: true, using: :btree

  create_table "reports", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.uuid     "customer_id"
    t.date     "month"
    t.integer  "count"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "reports", ["customer_id"], name: "index_reports_on_customer_id", using: :btree

  create_table "signups", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.text     "instagram_id"
    t.text     "instagram_username"
    t.text     "instagram_profile_picture"
    t.text     "timezone"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.text     "payment_method_nonce"
    t.text     "payment_method_type"
    t.datetime "completed_at"
    t.uuid     "plan_id"
    t.text     "access_token"
    t.text     "access_token_key"
    t.text     "access_token_iv"
    t.text     "email"
    t.text     "email_key"
    t.text     "email_iv"
  end

  add_index "signups", ["instagram_id"], name: "index_signups_on_instagram_id", using: :btree
  add_index "signups", ["plan_id"], name: "index_signups_on_plan_id", using: :btree

  create_table "subscriptions", force: :cascade do |t|
    t.uuid     "customer_id"
    t.uuid     "plan_id"
    t.text     "transaction_id"
    t.date     "end_date"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.date     "start_date"
  end

  add_index "subscriptions", ["customer_id"], name: "index_subscriptions_on_customer_id", using: :btree
  add_index "subscriptions", ["plan_id"], name: "index_subscriptions_on_plan_id", using: :btree

  create_table "visitors", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.text     "ip"
    t.text     "referrer"
    t.text     "path"
    t.text     "user_agent"
    t.hstore   "parameters",  default: {}, null: false
    t.datetime "created_at",               null: false
    t.uuid     "customer_id"
  end

  add_index "visitors", ["customer_id"], name: "index_visitors_on_customer_id", using: :btree
  add_index "visitors", ["parameters"], name: "index_visitors_on_parameters", using: :gin

  add_foreign_key "events", "customers"
  add_foreign_key "events", "visitors"
  add_foreign_key "instagram_session_logs", "instagram_sessions"
  add_foreign_key "reports", "customers"
  add_foreign_key "subscriptions", "customers"
  add_foreign_key "subscriptions", "plans"
  add_foreign_key "visitors", "customers"
end
