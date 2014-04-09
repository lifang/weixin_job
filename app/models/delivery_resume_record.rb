#encoding: utf-8
class DeliveryResumeRecord < ActiveRecord::Base
  belongs_to :company
  belongs_to :position
  belongs_to :client_resume

  STATUS = {:newest =>0,:refuse =>1,:audition =>2,:pass =>3}#最新，拒绝，面试，入职
end
