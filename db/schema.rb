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

ActiveRecord::Schema.define(:version => 20140409081029) do

  create_table "cities", :force => true do |t|
    t.integer  "order_index"
    t.string   "name"
    t.integer  "parent_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "client_html_infos", :force => true do |t|
    t.integer  "client_id"
    t.text     "hash_content"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.text     "html_content"
  end

  create_table "client_resumes", :force => true do |t|
    t.text     "html_content_datas"
    t.integer  "resume_template_id",                   :null => false
    t.boolean  "has_completed",      :default => true
    t.string   "open_id"
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
    t.integer  "company_id"
    t.string   "clint_name"
    t.string   "client_phone"
  end

  create_table "clients", :force => true do |t|
    t.string   "name"
    t.string   "mobiephone",      :limit => 45
    t.integer  "company_id"
    t.text     "html_content"
    t.integer  "types"
    t.string   "password"
    t.string   "username"
    t.string   "avatar_url"
    t.boolean  "has_new_message",               :default => false
    t.boolean  "has_new_record",                :default => false
    t.string   "open_id"
    t.boolean  "status",                        :default => false
    t.string   "remark"
    t.datetime "created_at",                                       :null => false
    t.datetime "updated_at",                                       :null => false
    t.string   "faker_id"
    t.string   "token"
    t.string   "wx_cookie"
    t.string   "wx_login_token"
  end

  add_index "clients", ["open_id"], :name => "by_open_id", :unique => true

  create_table "companies", :force => true do |t|
    t.string   "name"
    t.string   "root_path"
    t.integer  "status",                  :default => 1
    t.string   "cweb"
    t.boolean  "has_app",                 :default => false
    t.string   "app_account"
    t.string   "app_password"
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
    t.string   "company_account",                            :null => false
    t.string   "company_password",                           :null => false
    t.integer  "app_type"
    t.string   "app_id"
    t.string   "app_secret"
    t.boolean  "is_send_app_msg"
    t.boolean  "receive_status",          :default => false
    t.datetime "not_receive_start_at"
    t.datetime "not_receive_end_at"
    t.boolean  "app_service_certificate", :default => false
  end

  create_table "company_profiles", :force => true do |t|
    t.integer  "company_id",   :null => false
    t.text     "html_content"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.string   "title"
    t.string   "file_path"
  end

  create_table "delivery_resume_records", :force => true do |t|
    t.integer  "company_id",                      :null => false
    t.integer  "position_id",                     :null => false
    t.integer  "client_resume_id",                :null => false
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
    t.string   "recomender_id"
    t.integer  "status",           :default => 0
    t.datetime "audition_time"
    t.string   "audition_addr"
    t.string   "remark"
    t.datetime "join_time"
    t.string   "join_addr"
    t.string   "join_remark"
  end

  add_index "delivery_resume_records", ["recomender_id"], :name => "index_delivery_resume_records_on_recomender_id"

  create_table "export_records", :force => true do |t|
    t.datetime "begin_time"
    t.datetime "end_time"
    t.integer  "company_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "form_datas", :force => true do |t|
    t.integer  "client_resume_id"
    t.text     "data_hash"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "form_datas", ["client_resume_id"], :name => "index_form_datas_on_client_resume_id"

  create_table "labels", :force => true do |t|
    t.integer  "company_id"
    t.integer  "tag_id"
    t.integer  "client_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "labels", ["client_id"], :name => "index_labels_on_client_id"
  add_index "labels", ["company_id"], :name => "index_labels_on_company_id"
  add_index "labels", ["tag_id"], :name => "index_labels_on_tag_id"

  create_table "menus", :force => true do |t|
    t.string   "name"
    t.integer  "temp_id"
    t.integer  "parent_id",  :default => 0
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
    t.integer  "company_id"
    t.integer  "types"
    t.string   "file_path"
  end

  create_table "messages", :force => true do |t|
    t.integer  "company_id"
    t.integer  "from_user"
    t.integer  "to_user"
    t.integer  "types"
    t.text     "content"
    t.boolean  "status",       :default => false
    t.string   "msg_id"
    t.integer  "message_type", :default => 0
    t.string   "message_path"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

  add_index "messages", ["msg_id"], :name => "by_msg_id", :unique => true

  create_table "position_address_relations", :force => true do |t|
    t.integer  "position_id",     :null => false
    t.integer  "work_address_id", :null => false
    t.integer  "company_id",      :null => false
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
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
    t.text     "description"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.integer  "menu_id"
    t.integer  "company_id"
    t.integer  "position_type_id"
  end

  create_table "recently_clients", :force => true do |t|
    t.integer  "company_id"
    t.integer  "client_id"
    t.text     "content"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "records", :force => true do |t|
    t.integer  "company_id"
    t.text     "content"
    t.string   "title"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "records", ["company_id"], :name => "index_records_on_company_id"

  create_table "reminds", :force => true do |t|
    t.integer  "company_id"
    t.string   "content"
    t.date     "reseve_time"
    t.string   "title"
    t.boolean  "range"
    t.integer  "days"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "reminds", ["company_id"], :name => "index_reminds_on_company_id"

  create_table "resume_templates", :force => true do |t|
    t.text     "html_content"
    t.integer  "company_id",   :null => false
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.string   "html_url"
  end

  create_table "tags", :force => true do |t|
    t.string   "content"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "company_id"
  end

  create_table "work_addresses", :force => true do |t|
    t.string   "address"
    t.integer  "city_id",    :null => false
    t.integer  "company_id", :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

end
