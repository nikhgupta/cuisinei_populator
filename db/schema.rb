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

ActiveRecord::Schema.define(version: 20151006064616) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string   "namespace"
    t.text     "body"
    t.string   "resource_id",   null: false
    t.string   "resource_type", null: false
    t.integer  "author_id"
    t.string   "author_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id", using: :btree
  add_index "active_admin_comments", ["namespace"], name: "index_active_admin_comments_on_namespace", using: :btree
  add_index "active_admin_comments", ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id", using: :btree

  create_table "cities", force: :cascade do |t|
    t.string   "name",                                                         null: false
    t.string   "state",                                                        null: false
    t.string   "country",                                                      null: false
    t.decimal  "lat_pos",                precision: 13, scale: 10
    t.decimal  "lng_pos",                precision: 13, scale: 10
    t.decimal  "lat_min",                precision: 13, scale: 10
    t.decimal  "lat_max",                precision: 13, scale: 10
    t.decimal  "lng_min",                precision: 13, scale: 10
    t.decimal  "lng_max",                precision: 13, scale: 10
    t.integer  "population"
    t.integer  "census_year"
    t.integer  "priority",                                         default: 0
    t.integer  "places_count",                                     default: 0
    t.integer  "completed_places_count",                           default: 0
    t.datetime "geocoded_at"
    t.datetime "completed_at"
    t.datetime "created_at",                                                   null: false
    t.datetime "updated_at",                                                   null: false
  end

  add_index "cities", ["name", "state", "country"], name: "index_cities_on_name_and_state_and_country", unique: true, using: :btree

  create_table "items", force: :cascade do |t|
    t.integer  "place_id"
    t.string   "name"
    t.text     "description"
    t.integer  "cost"
    t.string   "min_time"
    t.string   "max_time"
    t.text     "extra"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "items", ["place_id"], name: "index_items_on_place_id", using: :btree

  create_table "menu_images", force: :cascade do |t|
    t.integer  "place_id"
    t.text     "url"
    t.string   "type"
    t.boolean  "consumer_upload"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "menu_images", ["place_id"], name: "index_menu_images_on_place_id", using: :btree

  create_table "places", force: :cascade do |t|
    t.integer  "city_id",                                                  null: false
    t.string   "title"
    t.text     "address"
    t.decimal  "lat",                precision: 13, scale: 10
    t.decimal  "lng",                precision: 13, scale: 10
    t.string   "establishment_name"
    t.integer  "ref_id"
    t.decimal  "ref_rating",         precision: 3,  scale: 2
    t.integer  "ref_votes_count",                              default: 0
    t.text     "raw_snippet"
    t.integer  "locked_by"
    t.integer  "items_count",                                  default: 0
    t.datetime "completed_at"
    t.datetime "created_at",                                               null: false
    t.datetime "updated_at",                                               null: false
  end

  create_table "taggings", force: :cascade do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       limit: 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true, using: :btree
  add_index "taggings", ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context", using: :btree

  create_table "tags", force: :cascade do |t|
    t.string  "name"
    t.integer "taggings_count", default: 0
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true, using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.integer  "workables_count",        default: 0
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.boolean  "admin"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  add_foreign_key "items", "places"
  add_foreign_key "menu_images", "places"
end
