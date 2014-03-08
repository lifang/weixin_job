#encoding: utf-8
class FormData < ActiveRecord::Base
  self.table_name = "form_datas"
   attr_accessible :page_id, :data_hash, :user_id
   belongs_to :page
   belongs_to :user
   serialize :data_hash
end
