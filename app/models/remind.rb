#encoding:utf-8
class Remind < ActiveRecord::Base
  belongs_to :company
  attr_protected :authenticate
  SEND_TIME = {:SELECT => 0, :ENTER => 1}  #0 => 选择，1 => 输入
  RANGE = {:EVERYONE => 0, :PERSONAL => 1 } #0 => 所有人，1 => 个人
end
