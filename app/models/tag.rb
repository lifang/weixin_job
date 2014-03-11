#encoding: utf-8
class Tag < ActiveRecord::Base
  belongs_to :company
  has_many :labels
  has_many :clients, :through => :labels

  attr_accessible :content
end
