#encoding:utf-8
module ApplicationHelper
  MW_URL = "http://demo.sunworldmedia.com/" #服务器地址

  def is_hover?(*controller_name)
    controller_name.each do |name|
      if request.url.include?(name)
        return "hover"
      else
        return ""
      end
    end
  end

  MW_URL = "http://demo.sunworldmedia.com" #服务器地址

  WEIXIN_OPEN_URL = "https://api.weixin.qq.com"  #微信api地址
  WEIXIN_DOWNLOAD_URL = "http://file.api.weixin.qq.com"  #微信文件地址
  DOWNLOAD_RESOURCE_ACTION = "/cgi-bin/media/get?access_token=%s&media_id=%s"  #微信下载资源 action
  GET_USER_INFO_ACTION = "/cgi-bin/user/info?access_token=%s&openid=%s&lang=zh_CN" #微信获取用户基本信息action
  ACCESS_TOKEN_ACTION = "/cgi-bin/token?grant_type=client_credential&appid=%s&secret=%s" #微信获取access_token action
  CREATE_MENU_ACTION = "/cgi-bin/menu/create?access_token=%s"
end
