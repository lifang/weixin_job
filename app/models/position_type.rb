#encoding: utf-8
class PositionType < ActiveRecord::Base
  belongs_to :company
  has_many :positions, :dependent=>:destroy
end
