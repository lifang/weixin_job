#encoding: utf-8
class ResumeTemplate < ActiveRecord::Base
  serialize :html_content
  belongs_to :company
  has_many :client_resumes
end
