#encoding: utf-8
class ClientResume < ActiveRecord::Base
  belongs_to :resume_template
  has_many :delivery_resume_records
end
