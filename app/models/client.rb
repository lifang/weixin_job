class Client < ActiveRecord::Base
  require "json"
  belongs_to :company
  attr_protected :authenticate
  TYPES = {:ADMIN => 0, :CONCERNED => 1}  #0 管理员(从IOS设备上登陆的人)，1关注的用户
  HAS_NEW_MESSAGE = {:NO => 0, :YES => 1} #是否有新消息
  HAS_NEW_RECORD = {:NO => 0, :YES => 1}  #是否有新提醒
  STATUS = {:valid => 0, :invalid => 1}  #用户是否被屏蔽？ 0是正常， 1被屏蔽
  
  WEIXIN_URL = 'https://mp.weixin.qq.com' #微信公众号url
  WEIXIN_LOGIN_ACTION = "/cgi-bin/login?lang=zh_CN" #公众号后台登录action
  WEIXIN_USER_SETTING_ACTION = '/cgi-bin/settingpage?t=setting/index&action=index&token=%s&lang=zh_CN' #公众号设置页面action，获取自身faker_id
  WEIXIN_CONTACT_LIST_ACTION = "/cgi-bin/contactmanage?t=user/index&lang=zh_CN&pagesize=10&type=0&groupid=0&token=%s&pageidx=0" #获取关注者列表 action
  WEIXIN_GET_FRIEND_AVATAR_ACTION = "/cgi-bin/getheadimg?fakeid=%s&token=%s&lang=zh_CN" #公众号获得用户头像action
  WEIXIN_SEND_MESSAGE_ACTION = '/cgi-bin/singlesend?lang=zh_CN'

  def self.save_client_info(open_id, company)
    client = Client.find_by_open_id_and_company_id(open_id, company.id) #先查找是否存在当前关注者的信息
    if company.service_account?
      avatar_url = get_user_basic_info(open_id, company) #服务号根据api接口获取头像信息
      if client
        client.update_attribute(:avatar_url, avatar_url) if avatar_url != client.avatar_url
      else
        company.clients.create(:types => Client::TYPES[:CONCERNED], :open_id => open_id, :avatar_url => avatar_url)
      end
    else
      login_info = login_to_weixin(company)
      if login_info.present?
        wx_token, wx_cookie = login_info
        user_faker_id = get_self_fakeid(wx_cookie, wx_token) #获取自身faker_id
        friend_faker_id = get_friend_fakeid(wx_cookie, wx_token) #获取最新好友的faker_id
        
        gzh_client = Client.find_by_company_id_and_types(company.id, TYPES[:ADMIN]) #公众号client
        gzh_client.update_attributes(:faker_id =>user_faker_id, :wx_token => wx_token, :wx_cookie => wx_cookie) if gzh_client.faker_id != user_faker_id #更新公众号faker_id
        avatar_url = get_friend_avatar(wx_token, wx_cookie, friend_faker_id) #订阅号，获取头像
        if client
          client.update_attribute(:avatar_url, avatar_url) if avatar_url != client.avatar_url
        else
          company.clients.create(:types => Client::TYPES[:CONCERNED], :open_id => open_id, :avatar_url => avatar_url, :faker_id => friend_faker_id)
        end
      end
    end
  end

  def login_to_weixin(company)
    account = company.app_account
    pwd = company.app_password
    data_param = 'username=' + account +'&pwd=' + pwd +'&imgcode=''&f=json'
    http = set_http(WEIXIN_URL)

    wx_cookie, slave_user, slave_sid, token = "", nil, nil, nil
    http.request_post(WEIXIN_LOGIN_ACTION, data_param, {"x-requested-with" => "XMLHttpRequest",
        "referer" => "https://mp.weixin.qq.com/cgi-bin/loginpage?t=wxm2-login&lang=zh_CN"}) {|response|
      res_data = JSON response.body   #   {"Ret"=>302, "ErrMsg"=>"/cgi-bin/home?t=home/index&lang=zh_CN&token=155671926", "ShowVerifyCode"=>0,"ErrCode"=>0, "WtloginErrCode"=>0}
      #p res_data
      if res_data["ErrCode"] == 0
        wx_cookie_str = response['set-cookie']  #获取cookie的值
        #"slave_user=gh_91dc23d9899e; Path=/; Secure; HttpOnly, slave_sid=NjJyWU9CMllLYWNRS0w4Tk05YXk3NlRjR09MZVQzOUFNSGRVR3lEcG1Pc1lYS1BPMEZ5dVduNGdCQnRVYnZHRnpOdlF3UmllRVVRak50ZlZmTWs3TkZ1YmhLQWxJWWR3RXRWMXhxSzRPdkZFSjFLRUNiblFrcHB6c1ZkdHVNWE0=; Path=/; Secure; HttpOnly"
        p "++++++++++++++++++++++++++++++++"
        p wx_cookie_str
        slave_user = wx_cookie_str.scan(/slave_user=(\w+);/).flatten[0]  #当前登录用户
        p slave_user
        slave_sid = wx_cookie_str.scan(/slave_sid=(\w+=)/).flatten[0] #当前登录用户id
        p slave_sid

        wx_cookie = "slave_user=#{slave_user}; slave_sid=#{slave_sid};"
        msg =res_data["ErrMsg"]
        token = msg.scan(/token=(\d+)/).flatten[0] #登录后的token
      else
        message = "login error"
        return false
      end
    }
    if slave_user && slave_sid && token
      return [token, wx_cookie]
    else
      return false
    end
    
  end

  def get_self_fakeid(wx_cookie, token)
    http = set_http(WEIXIN_URL)
    user_fakeid = nil
    setting_action = WEIXIN_USER_SETTING_ACTION % token
    http.request_get(setting_action,{"Cookie" => wx_cookie} ) {|response|
      #p "----------------------------------"
      # p response
      fakeid_arr = response.body.scan(/fakeid=(\w+)/)
      user_fakeid = fakeid_arr.flatten[0]
    }
    user_fakeid
  end

  def get_new_friend_fakeid(wx_cookie, token)
    page_contact_action = WEIXIN_CONTACT_LIST_ACTION % token
    http = set_http(WEIXIN_URL)
    new_friend_faker_id = nil
    http.request_get(page_contact_action,{"Cookie" => wx_cookie} ) {|response|
      # p response
      f_id = Regexp.new('"id":([0-9]{4,20})')
      response.read_body do |str|   # read body now
        friend_faker_id = f_id.match(str).to_a[1]
        if !friend_faker_id.nil? && !friend_faker_id.empty?
          new_friend_faker_id = friend_faker_id
          break
        end
      end
    }
    new_friend_faker_id
  end

  #获取用户头像
  def get_friend_avatar(token, wx_cookie, friend_faker_id) #订阅号，获取头像
    avatar_url_action = WEIXIN_GET_FRIEND_AVATAR_ACTION % [friend_faker_id, token]
    http = set_http(WEIXIN_URL)
    avatar_path = ""
    http.request_get(avatar_url_action,{"Cookie" => wx_cookie} ) {|response|
      filename = friend_faker_id.to_s + ".jpg"  #临时文件不能取到扩展名
      weixin_avatar = "/public/companies/%s/" % @company.root_path + "weixin_avatar/"
      wx_full_avatar = Rails.root.to_s + weixin_avatar
      new_file_name = wx_full_avatar + filename
      FileUtils.mkdir_p(wx_full_avatar) unless Dir.exists?(wx_full_avatar)
      File.open(new_file_name, "wb")  {|f| f.write response.body }
      if File.exist?(new_file_name)
        avatar_path = "/allsites/%s/" % @company.root_path + "weixin_avatar/" + filename #保存进数据库的路径
      end
    }
    avatar_path
  end

  #订阅号主动发消息
  def self.send_single_message(company, content, receive_client_id)
    client = Client.find_by_id(receive_client_id)
    to_faker_id = client.faker_id if client
    gzh_client = Client.find_by_company_id_and_types(company.id, TYPES[:ADMIN]) #公众号client
    wx_token = gzh_client.wx_login_token
    wx_cookie = gzh_client.wx_cookie
    send_message_request(content, gzh_client, to_faker_id, wx_token,wx_cookie)
  end

  #取数据库里面的
  def send_message_request(company, content, gzh_client, to_faker_id, wx_token, wx_cookie)
    http = set_http(WEIXIN_URL)
    post_data = 't=ajax-response&type=1&content=%s&error=false&imgcode=&token=%s&ajax=1&tofakeid=' % [content, wx_token]   # fakeid = ?
    post_data = (post_data + to_faker_id).encode('utf-8')
    header = {"Cookie" => wx_cookie,
      "referer" => 'https://mp.weixin.qq.com/cgi-bin/singlemsgpage?&token=%s&fromfakeid=%s'+
        '&msgid=&source=&count=20&t=wxm-singlechat&lang=zh_CN' % [wx_token, gzh_client.faker_id]
    }  # 添加 HTTP header 里的 referer 欺骗腾讯服务器。如果没有此 HTTP header，将得到登录超时的错误。
    i = 0
    msg = ""
    http.request_post(WEIXIN_SEND_MESSAGE_ACTION, post_data, header) {|response|
      p "((((((((((((((((((((((((((((((((((((((((((((((((((((((((((("
      res =  JSON response.body
      if res["base_resp"]["ret"]== 0
        msg = "success"
      else
        login_info = login_to_weixin(company) #数据库的token超时，重新登录
        if login_info.present?
          wx_token, wx_cookie = login_info
         
          gzh_client.update_attributes(:wx_token => wx_token, :wx_cookie => wx_cookie) #更新公众号faker_id
          while i < 1
            send_message_request(company, content, gzh_client, to_faker_id, wx_token, wx_cookie)
            i += 1
          end
        end
      end
    }
    msg
  end
end
