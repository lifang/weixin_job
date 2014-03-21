#encoding:utf-8
module Weixin
  require "json"
  require 'net/http'
  require "uri"
  require 'openssl'

  Weixin_resource = "/public/companies/%d/weixin_resource/" #微信资源路径
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
  WEIXIN_GET_FRIEND_AVATAR_ACTION = "/misc/getheadimg?fakeid=%s&token=%s&lang=zh_CN" #公众号获得用户头像action
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

  #验证请求是否从微信发出
  def get_signature(cweb, timestamp, nonce)
    tmp_arr = [cweb, timestamp, nonce]
    tmp_arr = tmp_arr.compact.sort!
    tmp_str = tmp_arr.join
    tmp_encrypted_str = Digest::SHA1.hexdigest(tmp_str)
    tmp_encrypted_str
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


  #创建自定义菜单
  def create_menu
    access_token = get_access_token(@company)
    if access_token && access_token["access_token"]
      menu_str = @company.get_menu_by_website
      c_menu_action = CREATE_MENU_ACTION % access_token["access_token"]
      response = create_post_http(WEIXIN_OPEN_URL ,c_menu_action ,menu_str)
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

  #获取用户头像
  def get_friend_avatar(token, wx_cookie, friend_faker_id, company) #订阅号，获取头像
    avatar_url_action = WEIXIN_GET_FRIEND_AVATAR_ACTION % [friend_faker_id, token]
    http = set_http(WEIXIN_URL)
    avatar_path = ""
    http.request_get(avatar_url_action,{"Cookie" => wx_cookie} ) {|response|
      filename = friend_faker_id.to_s + ".jpg"  #临时文件不能取到扩展名
      weixin_avatar = "/public/companies/%d/" % company.id + "weixin_avatar/"
      wx_full_avatar = Rails.root.to_s + weixin_avatar
      new_file_name = wx_full_avatar + filename
      FileUtils.mkdir_p(wx_full_avatar) unless Dir.exists?(wx_full_avatar)
      File.open(new_file_name, "wb")  {|f| f.write response.body }
      if File.exist?(new_file_name)
        avatar_path = "/companies/%d/" % company.id + "weixin_avatar/" + filename #保存进数据库的路径
      end
    }
    avatar_path
  end

  #保存关注者信息
  def save_client_info(open_id, company)
    client = Client.find_by_open_id_and_company_id(open_id, company.id) #先查找是否存在当前关注者的信息
    if company.service_account? && self.app_service_certificate #是服务号并且是认证的
      avatar_url,nickname = get_user_basic_info(open_id, company) #服务号根据api接口获取头像信息  认证服务号
    else
      avatar_url, friend_faker_id, nickname = get_avatar_hack(company)  #订阅号 and 未认证服务号
    end
    if client
      begin
        client.update_attributes(:avatar_url => avatar_url,:name=> get_name(nickname), :faker_id => friend_faker_id)
      rescue
        client.update_attributes(:avatar_url => avatar_url,:name=> "游客", :faker_id => friend_faker_id)
      end
    else
      begin
        company.clients.create(:name => get_name(nickname), :mobiephone =>"", :remark => "无", :types => Client::TYPES[:CONCERNED], :open_id => open_id, :avatar_url => avatar_url, :faker_id => friend_faker_id)
      rescue
        company.clients.create(:name => "游客", :mobiephone =>"", :remark => "无", :types => Client::TYPES[:CONCERNED], :open_id => open_id, :avatar_url => avatar_url, :faker_id => friend_faker_id)
      end
    end
  end
  
  #根据open_id和token，保存用户的头像信息
  def get_user_basic_info(open_id, company)
    access_token = get_access_token(company)
    user_avatar_url = nil
    if access_token && access_token["access_token"]
      action = GET_USER_INFO_ACTION % [access_token["access_token"], open_id]
      user_info = create_get_http(WEIXIN_OPEN_URL, action)
      if user_info && user_info["subscribe"]==1
        user_avatar_url = user_info["headimgurl"]
        user_name = user_info["nickname"]
      end
    end
    [user_avatar_url,user_name]
  end


  #订阅号或者未认证的服务号  获取头像hack, 自身faker_id, 最新好友的faker_id
  def get_avatar_hack(company)
    login_info = login_to_weixin(company)
    if login_info.present?
      wx_token, wx_cookie = login_info
      user_faker_id = get_self_fakeid(wx_cookie, wx_token) #获取自身faker_id
      friend_faker_id, nickname = get_new_friend_fakeid_and_nickname(wx_cookie, wx_token) #获取最新好友的faker_id and nickname

      gzh_client = Client.find_by_company_id_and_types(company.id, Client::TYPES[:ADMIN]) #公众号client
      gzh_client.update_attributes(:faker_id =>user_faker_id) if gzh_client.faker_id != user_faker_id #更新公众号faker_id
      avatar_url = get_friend_avatar(wx_token, wx_cookie, friend_faker_id, company) #订阅号，获取头像
    end
    return [avatar_url, friend_faker_id, nickname]
  end


  #获取朋友faker_id
  def get_new_friend_fakeid_and_nickname(wx_cookie, token)
    page_contact_action = WEIXIN_CONTACT_LIST_ACTION % [10, token, 0]  #10 代表每页个数， 0代表第一页
    http = set_http(WEIXIN_URL)
    new_friend_faker_id, nick_name = nil, nil
    http.request_get(page_contact_action,{"Cookie" => wx_cookie} ) {|response|
      f_id_reg = Regexp.new('"id":([0-9]{4,20})')
      nick_name_reg = Regexp.new('"nick_name":"([^"]+)"')
      response.read_body do |str|   # read body now
        friend_faker_id = f_id_reg.match(str).to_a[1]
        nickname = nick_name_reg.match(str).to_a[1]
        if friend_faker_id.present? && nickname.present?
          new_friend_faker_id = friend_faker_id
          nick_name = nickname
          break
        end
      end
    }
    [new_friend_faker_id, nick_name]
  end

  #订阅号主动发消息
  def send_single_message(company, content, receive_client_id)
    client = Client.find_by_id(receive_client_id)
    to_faker_id = client.faker_id if client
    gzh_client = Client.find_by_company_id_and_types(company.id, Client::TYPES[:ADMIN]) #公众号client
    wx_token = gzh_client.wx_login_token
    wx_cookie = gzh_client.wx_cookie
    msg = send_message_request(company,content, gzh_client, to_faker_id, wx_token,wx_cookie)
    msg
  end

  #取数据库里面的微信后台登陆的 token and cookie
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
      res =  JSON response.body
      if res["base_resp"]["ret"]== 0
        msg = "success"
      else #数据库的token超时，重新登录
        login_info = login_to_weixin(company)
        if login_info.present?
          wx_token, wx_cookie = login_info

          while i < 2
            send_message_request(company, content, gzh_client, to_faker_id, wx_token, wx_cookie)
            i += 1
          end
        end
      end
    }
    msg
  end

  #获取自身faker_id
  def get_self_fakeid(wx_cookie, token)
    http = set_http(WEIXIN_URL)
    user_fakeid = nil
    setting_action = WEIXIN_USER_SETTING_ACTION % token
    http.request_get(setting_action,{"Cookie" => wx_cookie} ) {|response|
      fakeid_arr = response.body.scan(/fakeid=(\w+)/)
      user_fakeid = fakeid_arr.flatten[0]
    }
    user_fakeid
  end


  #保存图片，语音进public目录下
  def save_image_or_voice_from_wx(flag)
    msg_id = params[:xml][:MsgId]
    open_id = params[:xml][:FromUserName]
    client = Client.find_by_open_id_and_status(open_id, Client::STATUS[:valid])  #查询有效用户
    if client
      if flag == "image" #图片
        file_extension = ".jpg"
        remote_resource_url = params[:xml][:PicUrl]
        message_path = save_file(remote_resource_url, file_extension, msg_id) #保存图片资源路径
      else #语音
        if @company.service_account? && @company.app_service_certificate #服务号认证
          access_token = get_access_token(@company)
          if access_token && access_token["access_token"]
            media_id = params[:xml][:MediaId]
            download_action = DOWNLOAD_RESOURCE_ACTION % [access_token["access_token"], media_id]
            remote_resource_url = (WEIXIN_DOWNLOAD_URL + download_action)
            file_extension = ".amr"

            http = set_http(WEIXIN_DOWNLOAD_URL)
            request= Net::HTTP::Get.new(download_action)
            back_res = http.request(request)
            if back_res && back_res[:errcode].nil? && back_res["Content-Type"] == "audio/amr" #认证服务号
              message_path = save_file(remote_resource_url, file_extension, msg_id) #保存语音资源路径
            end
          end
        else  #订阅号 and 未认证服务号
          message_path = get_voice_path_or_faker_id(@company, "voice")
        end
      end
      get_client_message(message_path) if message_path
    end
  end


  #接收用户的任何信息
  def get_client_message(wx_resource_url=nil)
    open_id = params[:xml][:FromUserName]
    if @company
      current_client =  Client.where("company_id=#{@company.id} and types = #{Client::TYPES[:ADMIN]}")[0]  #后台登陆人员
      client = Client.find_by_open_id_and_status(open_id, Client::STATUS[:valid])  #查询有效用户
      if @company.has_app && client && current_client && client.update_attribute(:has_new_message,true)
        time_now = Time.now.strftime("%H:%M")

        Message.transaction do
          begin
            m = Message.find_by_msg_id(params[:xml][:MsgId].to_s)
            if m.nil?
              p 111111111111111111111
              msg_type_value = Message::MSG_TYPE[params[:xml][:MsgType].to_sym]
              content = params[:xml][:Content]
              unless params[:xml][:Content].present?
                content = msg_type_value == 1 ? "图片" : "语音"
              end
              mess = Message.create!(:company_id => @company.id , :from_user => client.id ,:to_user => current_client.id ,
                :types => Message::TYPES[:weixin], :content => content,
                :status => Message::STATUS[:UNREAD], :msg_id => params[:xml][:MsgId],
                :message_type => msg_type_value, :message_path => wx_resource_url)
              p mess
              if mess && (!@company.receive_status || !(@company.receive_status && @company.not_receive_start_at && @company.not_receive_end_at && time_now >= @site.not_receive_start_at.strftime("%H:%M") && time_now <= @site.not_receive_end_at.strftime("%H:%M")))
                #推送到IOS端
                p "000000000000000000000"
                APNS.host = 'gateway.sandbox.push.apple.com'
                APNS.pem  = File.join(Rails.root, 'config', 'CMR_Development.pem')
                APNS.port = 2195
                token = current_client.token
                if token
                  badge = Client.where(["company_id=? and types=? and has_new_message=?", @company.id, Client::TYPES[:CONCERNED],
                      Client::HAS_NEW_MESSAGE[:YES]]).length
                  content = "#{client.name}:#{mess.content}"
                  APNS.send_notification(token,:alert => content, :badge => badge, :sound => client.id)
                  recent_client = RecentlyClients.find_by_company_id_and_client_id(@company.id, client.id)
                  if recent_client
                    recent_client.update_attributes!(:content => mess.content)
                  else
                    RecentlyClients.create!(:company_id => @company.id, :client_id => client.id, :content => mess.content)
                  end
                end
              end
            end
          rescue
            msg = "出错了"
          end
        end

      end
    end
  end

  #保存用户发送的图片，语音 （认证的服务号的语音，以及所有公众号的图片）
  def save_file(remote_resource_url, file_extension, msg_id)
    tmp_file = open(remote_resource_url) #打开直接下载链接
    filename = msg_id + file_extension  #临时文件不能取到扩展名
    weixin_resource = Weixin_resource % @company.id
    wx_full_resource = Rails.root.to_s + weixin_resource
    new_file_name = wx_full_resource + filename
    FileUtils.mkdir_p(wx_full_resource) unless Dir.exists?(wx_full_resource)
    File.open(new_file_name, "wb")  {|f| f.write tmp_file.read }
    if File.exist?(new_file_name)
      message_path = "/companies/%d/" % @company.id + "weixin_resource/" + filename #保存进数据库的路径
    end
    message_path
  end
  
  #保存语音消息 hack
  def get_voice_path_or_faker_id(company, flag)
    gzh_client = Client.find_by_company_id_and_types(company.id, Client::TYPES[:ADMIN]) #公众号client
    wx_token = gzh_client.wx_login_token
    wx_cookie = gzh_client.wx_cookie
    newest_msg_id, faker_id = get_newest_message_id_and_faker_id(wx_token, wx_cookie)
    if !newest_msg_id
      login_info = login_to_weixin(company)
      if login_info.present?
        wx_token, wx_cookie = login_info
        newest_msg_id, faker_id = get_newest_message_id_and_faker_id(wx_token, wx_cookie)
        if newest_msg_id.present? && flag == "voice"
          #download 语音消息
          message_path = download_voice_message(newest_msg_id,wx_token, wx_cookie)
          return message_path #返回保存下来的音频路径
        else
          return faker_id  #返回 faker_id
        end
      end
    else
      #download 语音消息
      if flag == "voice"
        message_path = download_voice_message(newest_msg_id,wx_token, wx_cookie)
        return message_path  #返回保存下来的音频路径
      else
        return faker_id  #返回 faker_id
      end
    end

  end


  #取最新消息  #消息id
  def get_newest_message_id_and_faker_id(wx_token, wx_cookie)
    http = set_http(WEIXIN_URL)
    action = WEIXIN_GET_MESSAGE_ACTION % wx_token
    msg_id, faker_id = nil, nil
    http.request_get(action,{"Cookie" => wx_cookie} ) {|response|
      res = response.body
      m_id = Regexp.new('"id":([0-9]{4,20})')
      faker_id = Regexp.new('"fakeid":"([0-9]{4,20})"')
      msg_arr = res.scan(m_id)
      faker_id_arr = res.scan(faker_id)
      msg_id = msg_arr.flatten[0]
      faker_id = faker_id_arr.flatten[0]
    }
    [msg_id,faker_id]
  end


  #下载语音消息
  def download_voice_message(msg_id,wx_token, wx_cookie)
    download_action = WEIXIN_DOWNLOAD_VOICE_ACTION % [msg_id, wx_token]
    http = set_http(WEIXIN_URL)
    back_res = nil
    http.request_get(download_action,{"Cookie" => wx_cookie} ) {|response|
      if response['content-type'] == "audio/mp3"
        back_res = response.body
      end
    }
    if back_res.present?
      filename = msg_id.to_s + ".mp3"  #下载下来默认是MP3
      weixin_resource = Weixin_resource % @company.id
      wx_full_resource = Rails.root.to_s + weixin_resource
      new_file_name = wx_full_resource + filename
      FileUtils.mkdir_p(wx_full_resource) unless Dir.exists?(wx_full_resource)
      File.open(new_file_name, "wb")  {|f| f.write back_res }
      if File.exist?(new_file_name)
        message_path = "/companies/%d/" % @company.id + "weixin_resource/" + filename #保存进数据库的路径
      end
    end
    message_path
  end

  #是否恢复app登记信息
  def return_app_regist_link
    message = "/companies/#{@company.id}/app_managements/app_regist"
    message = "&lt;a href='#{MW_URL + message}?secret_key=#{params[:xml][:FromUserName]}' &gt; 请点击登记您的信息&lt;/a&gt;"  #登记信息url
    xml = teplate_xml(message)
    render :xml => xml        #回复登记app的链接
  end

  #文本回复模板
  def teplate_xml(message)
    template_xml =
      <<Text
          <xml>
            <ToUserName><![CDATA[#{params[:xml][:FromUserName]}]]></ToUserName>
            <FromUserName><![CDATA[#{params[:xml][:ToUserName]}]]></FromUserName>
            <CreateTime>#{Time.now.to_i}</CreateTime>
            <MsgType><![CDATA[text]]></MsgType>
            <Content>#{message}</Content>
            <FuncFlag>0</FuncFlag>
          </xml>
Text
    template_xml
  end


  #*********************** 同步旧用户数据start ****************************

  #************************************ 认证服务号 ********************

  #认证服务号请求关注者列表
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
  #认证服务号根据open_id 获取基本信息，保存
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
        client = Client.find_by_open_id(open_id)
        if client
          unless client.name.present? && client.avatar_url.present?
            user_info = create_get_http(WEIXIN_OPEN_URL, action)
            if user_info && user_info["subscribe"] == 1
              client_attributes = {:company_id => company.id, :name => get_name(user_info["nickname"]), :open_id => user_info["openid"], :avatar_url => user_info["headimgurl"],:types => Client::TYPES[:CONCERNED]}
              begin
                client.update_attributes(client_attributes)
              rescue
                client_attributes[:name] = "游客"
                client.update_attributes(client_attributes)
              end
            else
              status = -1
            end
          end
        else
          user_info = create_get_http(WEIXIN_OPEN_URL, action)
          if user_info && user_info["subscribe"] == 1
            client_attributes = {:company_id => company.id, :mobiephone => "", :name => get_name(user_info["nickname"]), :open_id => user_info["openid"], :avatar_url => user_info["headimgurl"],:types => Client::TYPES[:CONCERNED]}
            begin
              Client.create(client_attributes)
            rescue
              client_attributes[:name] = "游客"
              Client.create(client_attributes)
            end
          else
            status = -1
          end
        end
        #        user_info = create_get_http(WEIXIN_OPEN_URL, action)
        #        if user_info && user_info["subscribe"] == 1
        #          client_attributes = {:company_id => company.id, :name => user_info["nickname"], :open_id => user_info["openid"], :avatar_url => user_info["headimgurl"],:types => Client::TYPES[:CONCERNED]}
        #          if client
        #            begin
        #              client.update_attributes(client_attributes)
        #            rescue
        #              client_attributes[:name] = "游客"
        #              client.update_attributes(client_attributes)
        #            end
        #          else
        #            begin
        #              Client.create(client_attributes)
        #            rescue
        #              p "333333333333333333333333"
        #              client_attributes[:name] = "游客"
        #              Client.create(client_attributes)
        #            end
        #          end
        #        else
        #          status = -1
        #        end
      end
    end
  end

  #************************************ 订阅号 and 未认证的服务号 ********************

  #获取朋友faker_id
  def get_friend_list(wx_cookie, token, company)
    total_count = get_friend_total_count(token, wx_cookie, 1, 0) #1代表每页个数， 0代表第几页 这一次取关注者总数
    total_page, perpage = pagecount(total_count)
    total_page.times do |i|
      sleep 2
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
    save_user_info_from_page(client_arr, company, token, wx_cookie) if company
    total_count
  end

  #保存用户信息
  def save_user_info_from_page(client_arr, company, wx_token, wx_cookie)
    #{"id"=>2166217981, "nick_name"=>"\u542C\u96EA", "remark_name"=>"", "group_id"=>0}
    client_arr.each do |client_hash|
      faker_id = client_hash["id"]
    
      client = Client.where(:faker_id => faker_id, :company_id => company.id )[0]
      if client.present?
        avatar_url = return_avatar_url(wx_token, wx_cookie,faker_id, company)
        client_attr = {:name => client_hash["remark_name"].present? ? get_name(client_hash["remark_name"]) : get_name(client_hash["nick_name"]),
          :faker_id => faker_id}
        begin
          if avatar_url
            client.update_attributes(client_attr.merge({:avatar_url => avatar_url}))
          else
            client.update_attributes(client_attr)
          end
        rescue
          if avatar_url
            client.update_attributes({:name => "游客",:faker_id => faker_id, :avatar_url => avatar_url})
          else
            client.update_attributes({:name => "游客",:faker_id => faker_id})
          end
        end
      else
        avatar_url = return_avatar_url(wx_token, wx_cookie,faker_id, company)
        client_attr = {:name => client_hash["remark_name"].present? ? get_name(client_hash["remark_name"]) : get_name(client_hash["nick_name"]),
          :faker_id => faker_id,:company_id => company.id, :types => Client::TYPES[:CONCERNED], :avatar_url => avatar_url,
          :mobiephone => ""}
        begin
          Client.create(client_attr)
        rescue
          client_attr[:name] = "游客"
          Client.create(client_attr)
        end
      end
    end
  end

  def return_avatar_url(wx_token, wx_cookie,faker_id, company)
    avatar_url = get_friend_avatar(wx_token, wx_cookie,faker_id, company) #订阅号，获取头像
    if avatar_url.blank?
      login_info = login_to_weixin(company)
      if login_info.present?
        wx_token, wx_cookie = login_info
        avatar_url = get_friend_avatar(wx_token, wx_cookie,faker_id, company) #订阅号，获取头像
      end
    end
    avatar_url
  end

  #******************************** 同步旧用户数据end *******************************************




  #自定义菜单，点击事件，返回对应链接
  def get_link_by_event_key(event_key, open_id)  #resume_5
    menu_type, temp_id = event_key.split("_")
    link = ""
    if menu_type == "resume"
      rt = ResumeTemplate.find_by_company_id(@company.id)
      if rt
        cr = ClientResume.where(:resume_template_id => rt.id, :open_id => open_id, :company_id => @company.id)[0]
        if cr
          message = "/client_resumes/#{cr.id}/edit?company_id=#{@company.id}&amp;secret_key=#{open_id}"
          link = "&lt;a href='#{MW_URL + message}' &gt; 点击查看简历 &lt;/a&gt;"  #简历url
        else
          message = rt.html_url
          link = "&lt;a href='#{MW_URL + message}?secret_key=#{open_id}' &gt; 点击填写简历 &lt;/a&gt;"  #简历url
        end
      end
    elsif menu_type == "positions"
      position_type = PositionType.find_by_id(temp_id) if temp_id
      positions = position_type.positions.where(:status => Position::STATUS[:RELEASED]) if position_type
      all_positions = "点击查看职位详情\n"
      positions.each do |position|
        message = "/companies/#{@company.id}/positions/#{position.id}"
        message = "&lt;a href='#{MW_URL + message}?secret_key=#{open_id}' &gt; #{position.try(:name)} &lt;/a&gt;\n"  #单个职位url
        all_positions += message
      end if positions
      link = positions.present? ? all_positions : ""
    end
    link
  end

  #处理名字
  def get_name(name)
    name.present? ? name : "无"
  end
  
end