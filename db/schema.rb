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

ActiveRecord::Schema.define(:version => 20130207022756) do

  create_table "assignments", :force => true do |t|
    t.integer  "user_id"
    t.integer  "project_id"
    t.boolean  "proposed",   :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "archived",   :default => false, :null => false
  end

  add_index "assignments", ["project_id", "user_id"], :name => "index_assignments_on_project_id_and_user_id", :unique => true

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

  create_table "memberships", :force => true do |t|
    t.integer "user_id"
    t.integer "company_id"
    t.boolean "disabled",                                            :default => false, :null => false
    t.boolean "archived",                                            :default => false, :null => false
    t.decimal "salary",               :precision => 12, :scale => 2
    t.decimal "rate",                 :precision => 10, :scale => 2
    t.decimal "full_time_equivalent", :precision => 12, :scale => 2
    t.string  "payment_frequency"
    t.integer "weekly_allocation"
    t.string  "employment_status",                                   :default => "fte", :null => false
    t.integer "permissions",                                         :default => 0,     :null => false
  end

  add_index "memberships", ["company_id", "user_id"], :name => "index_memberships_on_company_id_and_user_id", :unique => true

  create_table "projects", :force => true do |t|
    t.integer  "client_id"
    t.string   "name"
    t.boolean  "active",                                           :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "company_id"
    t.boolean  "proposed",                                         :default => false,   :null => false
    t.decimal  "cost",              :precision => 12, :scale => 2, :default => 0.0,     :null => false
    t.string   "payment_frequency",                                :default => "total", :null => false
  end

  create_table "user_preferences", :force => true do |t|
    t.boolean  "email_reminder"
    t.integer  "user_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "password_digest"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "current_company_id"
    t.string   "registration_token"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
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
    t.integer  "estimated_hours"
    t.integer  "actual_hours"
    t.integer  "cweek"
    t.integer  "year"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "assignment_id"
    t.decimal  "beginning_of_week", :precision => 15, :scale => 0
  end

end
