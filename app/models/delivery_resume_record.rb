#encoding: utf-8
class DeliveryResumeRecord < ActiveRecord::Base
  belongs_to :company
  belongs_to :position
  belongs_to :client_resume
end
