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

ActiveRecord::Schema.define(:version => 20120608184058) do

  create_table "clients", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.boolean  "active",      :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "company_id"
  end

  create_table "companies", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "companies_users", :id => false, :force => true do |t|
    t.integer "company_id"
    t.integer "user_id"
  end

  add_index "companies_users", ["company_id", "user_id"], :name => "index_companies_users_on_company_id_and_user_id"

  create_table "memberships", :force => true do |t|
    t.integer "user_id"
    t.integer "company_id"
    t.boolean "disabled",   :default => false, :null => false
    t.boolean "archived",   :default => false, :null => false
  end

  add_index "memberships", ["company_id", "user_id"], :name => "index_memberships_on_company_id_and_user_id", :unique => true

  create_table "projects", :force => true do |t|
    t.integer  "client_id"
    t.string   "name"
    t.boolean  "active",     :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "company_id"
    t.boolean  "proposed",   :default => false, :null => false
  end

  create_table "projects_users", :id => false, :force => true do |t|
    t.integer "user_id"
    t.integer "project_id"
  end

  add_index "projects_users", ["project_id"], :name => "index_projects_users_on_project_id"
  add_index "projects_users", ["user_id"], :name => "index_projects_users_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "password_digest"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "current_company_id"
    t.string   "registration_token"
    t.string   "first_name"
    t.string   "last_name"
  end

  create_table "versions", :force => true do |t|
    t.string   "item_type",  :null => false
    t.integer  "item_id",    :null => false
    t.string   "event",      :null => false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], :name => "index_versions_on_item_type_and_item_id"

  create_table "work_weeks", :force => true do |t|
    t.integer  "user_id"
    t.integer  "project_id"
    t.integer  "estimated_hours"
    t.integer  "actual_hours"
    t.integer  "cweek"
    t.integer  "year"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "work_weeks", ["user_id", "project_id", "cweek", "year"], :name => "index_work_weeks_on_user_id_and_project_id_and_cweek_and_year", :unique => true

end
