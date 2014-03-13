#encoding: utf-8
class ApplicationController < ActionController::Base
  protect_from_forgery
  include ApplicationHelper
  include PositionsHelper
  require 'net/http'
  require "uri"
  require 'openssl'

  WEIXIN_URL = 'https://mp.weixin.qq.com' #微信公众号url
  WEIXIN_LOGIN_ACTION = "/cgi-bin/login?lang=zh_CN" #公众号后台登录action
  WEIXIN_USER_SETTING_ACTION = '/cgi-bin/settingpage?t=setting/index&action=index&token=%s&lang=zh_CN' #公众号设置页面action，获取自身faker_id
  WEIXIN_CONTACT_LIST_ACTION = "/cgi-bin/contactmanage?t=user/index&lang=zh_CN&pagesize=10&type=0&groupid=0&token=%s&pageidx=0" #获取关注者列表 action
  WEIXIN_GET_FRIEND_AVATAR_ACTION = "/cgi-bin/getheadimg?fakeid=%s&token=%s&lang=zh_CN" #公众号获得用户头像action
  WEIXIN_SEND_MESSAGE_ACTION = '/cgi-bin/singlesend?lang=zh_CN'

  def has_sign?
    if cookies[:company_account].nil? || cookies[:company_id].nil? || cookies[:company_id] != Digest::MD5.hexdigest(params[:company_id])
      cookies.delete(:company_account)
      cookies.delete(:company_id)
      flash[:notice] = "请先登陆!"
      redirect_to logins_path
    else
      @company = Company.find_by_id(params[:company_id].to_i)
    end
  end
  
  def get_company
    @company = Company.find_by_id params[:company_id]
  end

  
  #微信所用开始

  #根据cweb参数，获取对应的公司
  def get_company_by_cweb
    cweb = params[:cweb]
    if cweb == "wansu" || cweb == "xyyd"
      @company = Company.find_by_cweb("xyyd")
    else
      @company = Company.find_by_cweb(cweb)
    end
    @company
  end

  #验证请求是否从微信发出
  def get_signature(cweb, timestamp, nonce)
    tmp_arr = [cweb, timestamp, nonce]
    tmp_arr = tmp_arr.compact.sort!
    tmp_str = tmp_arr.join
    tmp_encrypted_str = Digest::SHA1.hexdigest(tmp_str)
    tmp_encrypted_str
  end


  def save_into_file(content, page, old_file_name)
    site_root = page.site.root_path if page.site
    site_path = Rails.root.to_s + SITE_PATH % site_root
    FileUtils.mkdir_p(site_path) unless Dir.exists?(site_path)
    if old_file_name.present? && old_file_name != page.file_name
      File.delete site_path + old_file_name if File.exists?(site_path + old_file_name)
    end
    File.open(site_path + page.file_name, "wb") do |f|
      f.write(content.html_safe)
    end
    page.path_name = "/" + site_root + "/" + page.file_name
    page.save
  end

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

  #根据open_id和token，保存用户的头像信息
  def get_user_basic_info(open_id, company)
    access_token = get_access_token(company)
    user_avatar_url = nil
    if access_token and access_token["access_token"]
      action = GET_USER_INFO_ACTION % [access_token["access_token"], open_id]
      user_info = create_get_http(WEIXIN_OPEN_URL, action)
      if user_info && user_info["subscribe"]==1
        user_avatar_url = user_info["headimgurl"]
      end
    end
    user_avatar_url
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

  #获取自身faker_id
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

  #获取朋友faker_id
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
      weixin_avatar = "/public/companies/%d/" % @company.id + "weixin_avatar/"
      wx_full_avatar = Rails.root.to_s + weixin_avatar
      new_file_name = wx_full_avatar + filename
      FileUtils.mkdir_p(wx_full_avatar) unless Dir.exists?(wx_full_avatar)
      File.open(new_file_name, "wb")  {|f| f.write response.body }
      if File.exist?(new_file_name)
        avatar_path = "/companies/%d/" % @company.id + "weixin_avatar/" + filename #保存进数据库的路径
      end
    }
    avatar_path
  end

  #订阅号主动发消息
  def send_single_message(company, content, receive_client_id)
    client = Client.find_by_id(receive_client_id)
    to_faker_id = client.faker_id if client
    gzh_client = Client.find_by_company_id_and_types(company.id, Client::TYPES[:ADMIN]) #公众号client
    wx_token = gzh_client.wx_login_token
    wx_cookie = gzh_client.wx_cookie
    send_message_request(company,content, gzh_client, to_faker_id, wx_token,wx_cookie)
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

          gzh_client.update_attributes(:wx_login_token => wx_token, :wx_cookie => wx_cookie) #更新公众号faker_id
          while i < 1
            send_message_request(company, content, gzh_client, to_faker_id, wx_token, wx_cookie)
            i += 1
          end
        end
      end
    }
    msg
  end

  #公众号发消息给用户的模板
  def get_content_hash_by_type(open_id, msg_type, content, media_id=nil)
    content_hash = {}
    case msg_type
    when "text"
      content_hash = {
        :touser =>"#{open_id}",
        :msgtype => msg_type,
        :text =>
          {
          :content => content
        }
      }
    when "image"
      content_hash = {
        :touser =>"#{open_id}",
        :msgtype => msg_type,
        :image =>
          {
          :media_id => media_id
        }
      }
    when "voice"
      content_hash = {
        :touser =>"#{open_id}",
        :msgtype => msg_type,
        :voice =>
          {
          :media_id => media_id
        }
      }
    end
    content_hash = content_hash.to_json.gsub!(/\\u([0-9a-z]{4})/) {|s| [$1.to_i(16)].pack("U")}
    content_hash
  end
  #<>
  def encoding_character(str)
    arr={"<"=>"&lt;",">"=>"&gt;"}
    str.gsub(/<|>/){|s| arr[s]}
  end

end
