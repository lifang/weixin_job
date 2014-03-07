#encoding: utf-8
class PositionType < ActiveRecord::Base
  belongs_to :company
  has_many :positions, :dependent=>:destroy
  validate :name , :uniquess=>true,:message => "该名已存在!"
end
