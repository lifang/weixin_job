#encoding:utf-8
class Remind < ActiveRecord::Base
  attr_accessible :content, :range, :reseve_time, :site_id, :title,:days
  SEND_TIME = {:SELECT => 0, :ENTER => 1}  #0 => 选择，1 => 输入
  RANGE = {:EVERYONE => 0, :PERSONAL => 1 } #0 => 所有人，1 => 个人
end
