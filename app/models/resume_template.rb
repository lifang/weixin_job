#encoding: utf-8
class ResumeTemplate < ActiveRecord::Base
  belongs_to :company
  has_many :client_resumes
end
