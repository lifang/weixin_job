#encoding:utf-8
module Weixin
  require "json"
  require 'net/http'
  require "uri"
  require 'openssl'


  #认证服务号
  MW_URL = "http://wzpapp.gankao.co" #服务器地址
  WEIXIN_OPEN_URL = "https://api.weixin.qq.com"  #微信api地址
  WEIXIN_DOWNLOAD_URL = "http://file.api.weixin.qq.com"  #微信文件地址
  DOWNLOAD_RESOURCE_ACTION = "/cgi-bin/media/get?access_token=%s&media_id=%s"  #微信下载资源 action
  GET_USER_INFO_ACTION = "/cgi-bin/user/info?access_token=%s&openid=%s&lang=zh_CN" #微信获取用户基本信息action
  ACCESS_TOKEN_ACTION = "/cgi-bin/token?grant_type=client_credential&appid=%s&secret=%s" #微信获取access_token action
  CREATE_MENU_ACTION = "/cgi-bin/menu/create?access_token=%s" #创建自定义菜单action
  GET_USER_LIST_ACTION1 = "/cgi-bin/user/get?access_token=%s" #获取关注者列表action1
  GET_USER_LIST_ACTION2 = "/cgi-bin/user/get?access_token=%s&next_openid=%s" #获取关注者列表action2 超过10000个的时候


  #订阅号 hack action
  WEIXIN_URL = 'https://mp.weixin.qq.com' #微信公众号url
  WEIXIN_LOGIN_ACTION = "/cgi-bin/login?lang=zh_CN" #公众号后台登录action
  WEIXIN_USER_SETTING_ACTION = '/cgi-bin/settingpage?t=setting/index&action=index&token=%s&lang=zh_CN' #公众号设置页面action，获取自身faker_id
  WEIXIN_CONTACT_LIST_ACTION = "/cgi-bin/contactmanage?t=user/index&lang=zh_CN&pagesize=%d&type=0&groupid=0&token=%s&pageidx=%d" #获取关注者列表 action
  WEIXIN_GET_FRIEND_AVATAR_ACTION = "/cgi-bin/getheadimg?fakeid=%s&token=%s&lang=zh_CN" #公众号获得用户头像action
  WEIXIN_SEND_MESSAGE_ACTION = '/cgi-bin/singlesend?lang=zh_CN'  #公众号发送消息 action
  WEIXIN_GET_MESSAGE_ACTION = '/cgi-bin/message?t=message/list&count=5&day=0&token=%s&lang=zh_CN' #公众号获取消息列表 action
  WEIXIN_DOWNLOAD_VOICE_ACTION = '/cgi-bin/downloadfile?msgid=%d&source=&token=%s'  #公众号下载语音消息 action


  #根据app_id 和app_secret获取帐号token
  def get_access_token(company)
    app_id = company.app_id
    app_secret = company.app_secret
    token_action = ACCESS_TOKEN_ACTION % [app_id, app_secret]
    token_info = create_get_http(WEIXIN_OPEN_URL ,token_action)
    return token_info
  end

  #发get请求获得access_token
  def create_get_http(url ,route)
    http = set_http(url)
    request= Net::HTTP::Get.new(route)
    back_res = http.request(request)
    return JSON back_res.body
  end

  #发post请求创建自定义菜单
  def create_post_http(url,route_action,menu_bar)
    http = set_http(url)
    request = Net::HTTP::Post.new(route_action)
    request.set_body_internal(menu_bar)
    return JSON http.request(request).body
  end

  #设置http基本参数
  def set_http(url)
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    if uri.port==443
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end
    http
  end

  def service_account_get_user_list(access_token_val, company, next_open_id = nil)
    get_user_list_action = next_open_id.present? ? (GET_USER_LIST_ACTION2 % [access_token_val, next_open_id]) : (GET_USER_LIST_ACTION1 % access_token_val)
    user_list_info = Company.create_get_http(WEIXIN_OPEN_URL ,get_user_list_action)
    if user_list_info && user_list_info["errcode"].nil?
      count = user_list_info["count"] || 0
    end
    get_all_user_info(user_list_info, access_token_val, company) if count != 0#在helpers/weixin.rb
  end
  #根据获得的用户 open_id 列表
  #  {
  #  "total":23000,
  #  "count":10000,
  #  "data":{"
  #   openid":[
  #        "OPENID1",
  #        "OPENID2",
  #        ...,
  #        "OPENID10000"
  #     ]
  #   },
  #   "next_openid":"NEXT_OPENID1"
  #}
  def get_all_user_info(user_list_info, access_token_val, company)
    total_count = user_list_info["total"]
    status = 0
    if total_count > 10000
      next_open_id = user_list_info["next_openid"]
      service_account_get_user_list(access_token_val, company, next_open_id)
    else
      openid_list = user_list_info["data"]["openid"]
      openid_list.each_with_index do |open_id, index|
        action = GET_USER_INFO_ACTION % [access_token_val, open_id]

        user_info = create_get_http(WEIXIN_OPEN_URL, action)
        if user_info && user_info["subscribe"] == 1
          client = Client.find_by_open_id(open_id)
          client_attributes = {:company_id => company.id, :name => user_info["nickname"], :open_id => user_info["openid"], :avatar_url => user_info["headimgurl"],:types => Client::TYPES[:CONCERNED]}
          if client
            unless client.update_attributes(client_attributes)
              client_attributes[:name] = "游客"
              client.update_attributes(client_attributes)
            end
          else
            client = Client.create(client_attributes)
            unless client
              client_attributes[:name] = "游客"
              client.create(client_attributes)
            end
          end
        else
          status = -1
        end
      end
    end
  end

  
  #登录微信
  def login_to_weixin(company)
    account = company.app_account
    pwd = company.app_password
    data_param = 'username=' + account +'&pwd=' + pwd +'&imgcode=''&f=json'
    http = set_http(WEIXIN_URL)

    wx_cookie, slave_user, slave_sid, token = "", nil, nil, nil
    http.request_post(WEIXIN_LOGIN_ACTION, data_param, {"x-requested-with" => "XMLHttpRequest",
        "referer" => "https://mp.weixin.qq.com/cgi-bin/loginpage?t=wxm2-login&lang=zh_CN"}) {|response|
      res_data = JSON response.body   #   {"Ret"=>302, "ErrMsg"=>"/cgi-bin/home?t=home/index&lang=zh_CN&token=155671926", "ShowVerifyCode"=>0,"ErrCode"=>0, "WtloginErrCode"=>0}
      if res_data["ErrCode"] == 0
        wx_cookie_str = response['set-cookie']  #获取cookie的值
        #"slave_user=gh_91dc23d9899e; Path=/; Secure; HttpOnly, slave_sid=NjJyWU9CMllLYWNRS0w4Tk05YXk3NlRjR09MZVQzOUFNSGRVR3lEcG1Pc1lYS1BPMEZ5dVduNGdCQnRVYnZHRnpOdlF3UmllRVVRak50ZlZmTWs3TkZ1YmhLQWxJWWR3RXRWMXhxSzRPdkZFSjFLRUNiblFrcHB6c1ZkdHVNWE0=; Path=/; Secure; HttpOnly"
        slave_user = wx_cookie_str.scan(/slave_user=(\w+);/).flatten[0]  #当前登录用户
        slave_sid = wx_cookie_str.scan(/slave_sid=(\w+=)/).flatten[0] #当前登录用户id

        wx_cookie = "slave_user=#{slave_user}; slave_sid=#{slave_sid};"
        msg =res_data["ErrMsg"]
        token = msg.scan(/token=(\d+)/).flatten[0] #登录后的token

        gzh_client = Client.find_by_company_id_and_types(company.id, Client::TYPES[:ADMIN]) #公众号client
        gzh_client.update_attributes(:wx_login_token => token, :wx_cookie => wx_cookie) #更新公众号faker_id
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
  
  #获取朋友faker_id
  def get_friend_list(wx_cookie, token, company)
    total_count = get_friend_total_count(token, wx_cookie, 1, 0) #1代表每页个数， 0代表第几页 这一次取关注者总数
    total_page, perpage = pagecount(total_count)
    total_page.times do |i|
      get_friend_total_count(token, wx_cookie, perpage, i, company)
    end
 
  end

  #请求获取好友总数 以及匹配的关注者列表
  def get_friend_total_count(token, wx_cookie, perpage, index, company = nil)
    page_contact_action = WEIXIN_CONTACT_LIST_ACTION % [perpage, token, index]
    http = set_http(WEIXIN_URL)
    client_arr = []
    total_count = 0
    http.request_get(page_contact_action,{"Cookie" => wx_cookie} ) {|response|
      str = response.body
      #查找关注者总数
      total_user_regexp = Regexp.new('"cnt":([0-9]{1,6})')
     # p str
      total_count_arr = total_user_regexp.match(str).to_a
      total_count = total_count_arr[1].to_i
      contacts_reg = Regexp.new('"contacts":\[(\{.+\})\]')
      contacts_str = str.scan(contacts_reg).flatten[0] #"{\"id\":1366127225,\"nick_name\":\"\u90D1\u8D24\u7389\",\"remark_name\":\"\"},
      #{\"id\"::664229417,\"nick_name\":\"shevechenco\",\"remark_name\":\"\",\"group_id\":0}"  #一整个string
      if contacts_str
        contacts_str = contacts_str.force_encoding 'utf-8'
        user_hash_arr = contacts_str.scan(/(\{[^\{\}]+\})/u).flatten  #["{\"id\":1366127225,\"nick_name\":\"\u90D1\u8D24\u7389\",\"remark_name\":\"\"}",
        #"{\"id\"::664229417,\"nick_name\":\"shevechenco\",\"remark_name\":\"\",\"group_id\":0}"] #数组里面n个stringhash
        user_hash_arr.each do |str_hash|
          client_json = JSON.parse str_hash  #{"id"=>2166217981, "nick_name"=>"\u542C\u96EA", "remark_name"=>"", "group_id"=>0}
          client_arr << client_json
        end
      end
    }
    save_user_info_from_page(client_arr, company) if company
    total_count
  end

  #保存用户信息
  def save_user_info_from_page(client_arr, company)
    #{"id"=>2166217981, "nick_name"=>"\u542C\u96EA", "remark_name"=>"", "group_id"=>0}
    client_arr.each do |client_hash|
      client = Client.where(:faker_id => client_hash["id"], :company_id => company.id )[0]
      if client.present?
        unless client.update_attributes({:name => client_hash["remark_name"].present? ? client_hash["remark_name"] : client_hash["nick_name"],
            :faker_id => client_hash["id"]})
          client.update_attributes({:name => "游客",:faker_id => client_hash["id"]})
        end
      else
        client = Client.create({:name => client_hash["remark_name"].present? ? client_hash["remark_name"] : client_hash["nick_name"],
            :faker_id => client_hash["id"],:company_id => company.id, :types => Client::TYPES[:CONCERNED]})
        client = Client.create({:name => "游客",:faker_id => client_hash["id"],:company_id => company.id,
            :types => Client::TYPES[:CONCERNED]}) unless client
      end
    end
  end
end