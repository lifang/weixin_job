#encoding: utf-8
class Company < ActiveRecord::Base
  has_many :position_types
  has_many :resume_templates
  has_many :delivery_resume_records
  has_many :company_profiles
  #validate :name, :uniqueness => true, :allow_nil => false, :message => "该公司名称已被注册!"
  validate :company_account, :uniqueness => true, :allow_nil => false, :message => "该用户名已被注册!"

  STATUS = {:DELETED => 0, :NORMAL => 1}  #状态0删除，1正常
  HAS_APP = {:NO => false, :YES => true} #是否有APP
  APP_TYPE = {:SUBSCRIPTION => 0, :SERVICE => 1} #公众号类型0订阅号，1服务号
end