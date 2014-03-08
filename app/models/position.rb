#encoding: utf-8
class Position < ActiveRecord::Base
  belongs_to :company
  belongs_to :position_type
  has_many :delivery_resume_records, :dependent=>:destroy
  STATUS = {:DELETED => 0, :UNRELEASE => 1, :RELEASED => 2}  #状态 0已删除 1未发布 2已发布
end
