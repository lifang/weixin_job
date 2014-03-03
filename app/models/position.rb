#encoding: utf-8
class Position < ActiveRecord::Base
  belongs_to :position_type
  has_many :delivery_resume_records
end
