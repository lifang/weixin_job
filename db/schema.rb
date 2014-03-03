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

ActiveRecord::Schema.define(:version => 20140228094136) do

  create_table "client_resumes", :force => true do |t|
    t.string   "html_content_datas"
    t.integer  "resume_template_id",                   :null => false
    t.boolean  "has_completed",      :default => true
    t.string   "open_id"
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
  end

  create_table "companies", :force => true do |t|
    t.string   "name"
    t.string   "root_path"
    t.integer  "status",       :default => 1
    t.string   "cweb"
    t.boolean  "has_app",      :default => false
    t.string   "app_account"
    t.string   "app_password"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

  create_table "company_profiles", :force => true do |t|
    t.integer  "company_id",   :null => false
    t.string   "html_content"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "delivery_resume_records", :force => true do |t|
    t.integer  "company_id",       :null => false
    t.integer  "position_id",      :null => false
    t.integer  "client_resume_id", :null => false
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "position_types", :force => true do |t|
    t.string   "name",       :null => false
    t.integer  "company_id", :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "positions", :force => true do |t|
    t.string   "name"
    t.integer  "status"
    t.string   "requirement"
    t.string   "description"
    t.integer  "position_type_id", :null => false
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "resume_templates", :force => true do |t|
    t.string   "html_content"
    t.integer  "company_id",   :null => false
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

end
