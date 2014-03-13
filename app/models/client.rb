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

  def client_avatar_url
    if self.company.app_type == Company::APP_TYPE[:SUBSCRIPTION]  #订阅号
      avatar_url = ApplicationHelper::MW_URL + self.avatar_url.to_s
    else
      avatar_url = self.avatar_url
    end
    avatar_url
  end
end
