#encoding:utf-8
class WeixinsController < ApplicationController
  require 'digest/sha1'
  require 'net/http'
  require "uri"
  require 'openssl'
  require "open-uri"
  require "tempfile"
  before_filter :get_company_by_cweb  #根据cweb参数，获取对应的公司

  #用于处理相应服务号的请求以及一开始配置服务器时候的验证，post 或者 get
  def accept_token
    signature, timestamp, nonce, echostr, cweb = params[:signature], params[:timestamp], params[:nonce], params[:echostr], params[:cweb]
    tmp_encrypted_str = get_signature(cweb, timestamp, nonce)
    if request.request_method == "POST" && tmp_encrypted_str == signature
      if @company.present?
        open_id = params[:xml][:FromUserName]
        unless @company.service_account? && @company.app_service_certificate
          client = Client.find_by_open_id(open_id)
          if client
            if client.faker_id.blank?  #有open_id 没有 faker_id
              faker_id = get_voice_path_or_faker_id(@company, "faker_id")
              client.update_attribute(:faker_id, faker_id)
            end
          else
            faker_id = get_voice_path_or_faker_id(@company, "faker_id")
            client = @company.clients.where(:types => Client::TYPES[:CONCERNED], :faker_id => faker_id)[0]
            if client  # 有faker_id 没有 open_id  是老用户  同步来的
              client.update_attribute(:open_id, open_id)
            else
              
            end
          end

        end
        if params[:xml][:MsgType] == "event" && params[:xml][:Event] == "subscribe"   #用户关注事件
          return_app_regist_link  #返回app登记链接
          save_client_info(open_id, @company) #新建client记录，保存头像，faker_id, open_id
        
          create_menu if @company.app_id.present? && @company.app_secret.present?   #创建自定义菜单
        elsif params[:xml][:MsgType] == "text"   #用户发送文字消息
          #return_app_regist_link if @company.has_app #返回app登记链接
          #存储消息并推送到ios端
          get_client_message
          render :text => "ok"
        elsif params[:xml][:MsgType] == "image" #用户发送图片
          save_image_or_voice_from_wx("image")
          render :text => "ok"
        elsif params[:xml][:MsgType] == "voice" #用户发送语音
          save_image_or_voice_from_wx("voice")
          render :text => "ok"
        elsif params[:xml][:MsgType] == "event" && params[:xml][:Event] == "CLICK"  #自定义菜单点击事件
          message = get_link_by_event_key(params[:xml][:EventKey], open_id)  #resume_5
          if message.present?
            xml = teplate_xml(message)
            render :xml => xml        #回复登记app的链接
          else
            render :text => "ok"
          end
        else
          render :text => "ok"
        end
      else
        render :text => "ok"
      end
    elsif request.request_method == "GET" && tmp_encrypted_str == signature  #配置服务器token时是get请求
      render :text => tmp_encrypted_str == signature ? echostr :  false
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

  #是否恢复app登记信息
  def return_app_regist_link
    client = Client.find_by_open_id_and_status(params[:xml][:FromUserName], Client::TYPES[:CONCERNED])
    #unless client
    message = "/companies/#{@company.id}/app_managements/app_regist"
    message = "&lt;a href='#{MW_URL + message}?secret_key=#{params[:xml][:FromUserName]}' &gt; 请点击登记您的信息&lt;/a&gt;"  #登记信息url
    xml = teplate_xml(message)
    render :xml => xml        #回复登记app的链接
    #end
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


  #创建自定义菜单
  def create_menu
    access_token = get_access_token(@company)
    if access_token && access_token["access_token"]
      menu_str = @company.get_menu_by_website
      c_menu_action = CREATE_MENU_ACTION % access_token["access_token"]
      response = create_post_http(WEIXIN_OPEN_URL ,c_menu_action ,menu_str)
    end
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
            p back_res
            p back_res[:errcode]
            if back_res && back_res[:errcode].nil? #认证服务号
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

  #保存用户发送的图片，语音
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
      faker_id = Regexp.new('"faker_id":([0-9]{4,20})')
      msg_arr = res.scan(m_id)
      faker_id = res.scan(faker_id)
      msg_id = msg_arr.flatten[0]
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

  #保存关注者信息
  def save_client_info(open_id, company)
    client = Client.find_by_open_id_and_company_id(open_id, company.id) #先查找是否存在当前关注者的信息
    if company.service_account? && self.app_service_certificate #是服务号并且是认证的
      avatar_url = get_user_basic_info(open_id, company) #服务号根据api接口获取头像信息  认证服务号
    else
      avatar_url, friend_faker_id = get_avatar_hack(company)  #订阅号 and 未认证服务号
    end
    if client
      client.update_attributes(:avatar_url => avatar_url, :faker_id => friend_faker_id)
    else
      company.clients.create(:name => "游客", :mobiephone =>"", :remark => "无", :types => Client::TYPES[:CONCERNED], :open_id => open_id, :avatar_url => avatar_url, :faker_id => friend_faker_id)
    end
  end

  #订阅号或者未认证的服务号  获取头像hack
  def get_avatar_hack(company)
    login_info = login_to_weixin(company)
    if login_info.present?
      wx_token, wx_cookie = login_info
      user_faker_id = get_self_fakeid(wx_cookie, wx_token) #获取自身faker_id
      friend_faker_id = get_new_friend_fakeid(wx_cookie, wx_token) #获取最新好友的faker_id

      gzh_client = Client.find_by_company_id_and_types(company.id, Client::TYPES[:ADMIN]) #公众号client
      gzh_client.update_attributes(:faker_id =>user_faker_id) if gzh_client.faker_id != user_faker_id #更新公众号faker_id
      avatar_url = get_friend_avatar(wx_token, wx_cookie, friend_faker_id) #订阅号，获取头像
    end
    return [avatar_url, friend_faker_id]
  end

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

end