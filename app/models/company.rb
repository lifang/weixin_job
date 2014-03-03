#encoding: utf-8
class Company < ActiveRecord::Base
  has_many :position_types
  has_many :resume_templates
  has_many :delivery_resume_records
  has_many :company_profiles
end
