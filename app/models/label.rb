#encoding: utf-8
class Label < ActiveRecord::Base
  attr_accessible :client_id, :company_id, :tag_id
  belongs_to :client
  belongs_to :tag
end
