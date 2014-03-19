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

  #获得关注者头像
  def client_avatar_url
    if self.company.service_account? && self.app_service_certificate #是服务号并且是认证的
      avatar_url = self.avatar_url
    else
      avatar_url = ApplicationHelper::MW_URL + self.avatar_url.to_s
    end
    avatar_url
  end

end
