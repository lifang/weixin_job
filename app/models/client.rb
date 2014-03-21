#encoding: utf-8
class Client < ActiveRecord::Base
  require "json"
  belongs_to :company
  has_one :client_html_info
  has_many :labels
  has_many :tags, :through => :labels
  attr_protected :authenticate
  #serialize :html_content
  TYPES = {:ADMIN => 0, :CONCERNED => 1}  #0 管理员(从IOS设备上登陆的人)，1关注的用户
  HAS_NEW_MESSAGE = {:NO => 0, :YES => 1} #是否有新消息
  HAS_NEW_RECORD = {:NO => 0, :YES => 1}  #是否有新提醒
  STATUS = {:valid => 0, :invalid => 1}  #用户是否被屏蔽？ 0是正常， 1被屏蔽
  
  #  after_save :give_client_a_name

  #获得关注者头像
  def client_avatar_url
    if self.company && self.company.service_account? && self.company.app_service_certificate #是服务号并且是认证的
      avatar_url = self.avatar_url
    else
      avatar_url = Weixin::MW_URL + self.avatar_url.to_s
    end
    avatar_url
  end

  #client保存之后，如果没有名字，给个无名氏
  def give_client_a_name
    if self.types == TYPES[:CONCERNED] && self.name.blank?
      self.update_attribute(:name, "无名氏")
    end
  end
end
