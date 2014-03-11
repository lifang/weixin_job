#encoding: utf-8
class Record < ActiveRecord::Base
  belongs_to :company
  attr_accessible :content, :company_id, :title
end
