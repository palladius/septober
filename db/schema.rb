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

ActiveRecord::Schema.define(:version => 20110126170354) do

  create_table "projects", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.string   "color",        :default => "grey"
    t.boolean  "active",       :default => true
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "home_visible", :default => true
    t.boolean  "public",       :default => false
  end

  create_table "todos", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.boolean  "active",        :default => true
    t.date     "due"
    t.integer  "priority",      :default => 3
    t.integer  "user_id"
    t.integer  "project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "source",        :default => "web"
    t.string   "where"
    t.string   "url"
    t.integer  "depends_on_id"
  end

  create_table "users", :force => true do |t|
    t.string   "username"
    t.string   "email"
    t.string   "password_hash"
    t.string   "password_salt"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "facebook_id"
    t.boolean  "admin",         :default => false
  end

end
