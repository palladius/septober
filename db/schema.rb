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

ActiveRecord::Schema.define(:version => 20110206160046) do

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
    t.boolean  "system",       :default => false
    t.string   "photo_url"
  end

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context"
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type", "context"], :name => "index_taggings_on_taggable_id_and_taggable_type_and_context"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  create_table "todos", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.boolean  "active",          :default => true
    t.date     "due"
    t.integer  "priority",        :default => 3
    t.integer  "user_id"
    t.integer  "project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "source",          :default => "web"
    t.string   "where"
    t.string   "url"
    t.integer  "depends_on_id"
    t.datetime "hide_until"
    t.integer  "progress_status", :default => 0
    t.boolean  "favorite",        :default => false
    t.text     "sys_notes"
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
