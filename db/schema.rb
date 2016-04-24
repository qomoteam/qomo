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

ActiveRecord::Schema.define(version: 20160424091408) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"
  enable_extension "hstore"

  create_table "categories", force: :cascade do |t|
    t.string  "name"
    t.integer "parent_id"
    t.integer "lft",                        null: false
    t.integer "rgt",                        null: false
    t.integer "depth",          default: 0, null: false
    t.integer "children_count", default: 0, null: false
  end

  add_index "categories", ["lft"], name: "index_categories_on_lft", using: :btree
  add_index "categories", ["parent_id"], name: "index_categories_on_parent_id", using: :btree
  add_index "categories", ["rgt"], name: "index_categories_on_rgt", using: :btree

  create_table "filerecords", force: :cascade do |t|
    t.uuid    "owner_id"
    t.string  "path",                     null: false
    t.text    "desc"
    t.boolean "shared",   default: false
    t.string  "name"
  end

  add_index "filerecords", ["owner_id"], name: "index_filemeta_on_owner_id", using: :btree

  create_table "job_units", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.uuid     "job_id"
    t.uuid     "tool_id"
    t.string   "command"
    t.string   "wd"
    t.hstore   "env"
    t.json     "params"
    t.integer  "status",     default: 0
    t.datetime "started_at"
    t.datetime "ended_at"
    t.text     "log"
    t.integer  "idx"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "jobs", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.uuid     "user_id"
    t.text     "log"
    t.integer  "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pipelines", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "accession"
    t.string   "title"
    t.string   "contributors"
    t.text     "desc"
    t.uuid     "owner_id"
    t.json     "boxes"
    t.json     "connections"
    t.json     "params"
    t.boolean  "shared",       default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "panx",         default: 0
    t.integer  "pany",         default: 0
    t.integer  "category_id"
  end

  create_table "roles", force: :cascade do |t|
    t.string   "name"
    t.integer  "resource_id"
    t.string   "resource_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "roles", ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id", using: :btree
  add_index "roles", ["name"], name: "index_roles_on_name", using: :btree

  create_table "tools", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "name",                     null: false
    t.string   "contributors"
    t.uuid     "owner_id"
    t.integer  "category_id"
    t.text     "command"
    t.json     "params"
    t.text     "usage"
    t.integer  "status",       default: 0
    t.string   "dirname"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "desc"
    t.string   "tech"
  end

  add_index "tools", ["category_id"], name: "index_tools_on_category_id", using: :btree
  add_index "tools", ["name"], name: "index_tools_on_name", unique: true, using: :btree
  add_index "tools", ["owner_id"], name: "index_tools_on_owner_id", using: :btree

  create_table "users", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "username"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "title"
    t.string   "organization"
    t.string   "location"
    t.string   "timezone"
    t.string   "homepage"
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
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "users_roles", id: false, force: :cascade do |t|
    t.uuid    "user_id"
    t.integer "role_id"
  end

  create_table "votes", force: :cascade do |t|
    t.integer  "votable_id"
    t.string   "votable_type"
    t.integer  "voter_id"
    t.string   "voter_type"
    t.boolean  "vote_flag"
    t.string   "vote_scope"
    t.integer  "vote_weight"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "votes", ["votable_id", "votable_type", "vote_scope"], name: "index_votes_on_votable_id_and_votable_type_and_vote_scope", using: :btree
  add_index "votes", ["voter_id", "voter_type", "vote_scope"], name: "index_votes_on_voter_id_and_voter_type_and_vote_scope", using: :btree

end
