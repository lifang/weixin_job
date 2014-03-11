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
        if params[:xml][:MsgType] == "event" && params[:xml][:Event] == "subscribe"   #用户关注事件
          return_app_regist_link  #返回app登记链接
        
          open_id = params[:xml][:FromUserName]
          Client.save_client_info(open_id, @company) #新建client记录，保存头像，faker_id, open_id
        
          create_menu if @company.app_id.present? && @company.app_secret.present?   #创建自定义菜单
        elsif params[:xml][:MsgType] == "text"   #用户发送文字消息
          return_app_regist_link if @company.has_app #返回app登记链接
          #存储消息并推送到ios端
          get_client_message
        elsif params[:xml][:MsgType] == "image" #用户发送图片
          save_image_or_voice_from_wx("image")
          render :text => "ok"
        elsif params[:xml][:MsgType] == "voice" #用户发送语音
          save_image_or_voice_from_wx("voice")
          render :text => "ok"
        elsif params[:xml][:MsgType] == "click"  #自定义菜单点击事件
          
        else
          render :text => "ok"
        end
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
              msg_type_value = Message::MSG_TYPE[params[:xml][:MsgType].to_sym]
              content = params[:xml][:Content]
              unless params[:xml][:Content].present?
                content = msg_type_value == 1 ? "图片" : "语音"
              end
              mess = Message.create!(:company_id => @company.id , :from_user => client.id ,:to_user => current_client.id ,
                :types => Message::TYPES[:weixin], :content => content,
                :status => Message::STATUS[:UNREAD], :msg_id => params[:xml][:MsgId],
                :message_type => msg_type_value, :message_path => wx_resource_url)
              if mess && (!@company.receive_status || !(@company.receive_status && @company.not_receive_start_at && @company.not_receive_end_at && time_now >= @site.not_receive_start_at.strftime("%H:%M") && time_now <= @site.not_receive_end_at.strftime("%H:%M")))
                #推送到IOS端
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
    if client
      message = "/companies/#{@company.id}/app_managements/app_regist"
      message = "&lt;a href='#{MW_URL + message}?secret_key=#{params[:xml][:FromUserName]}' &gt; 请点击登记您的信息&lt;/a&gt;"  #登记信息url
      xml = teplate_xml(message)
      render :xml => xml        #回复登记app的链接
    end
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
    if access_token and access_token["access_token"]
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
      if flag == "image"
        file_extension = ".jpg"
        remote_resource_url = params[:xml][:PicUrl]

        save_file(remote_resource_url, file_extension, msg_id)
      else
        access_token = get_access_token(@company)
        if access_token and access_token["access_token"]
          media_id = params[:xml][:MediaId]
          download_action = DOWNLOAD_RESOURCE_ACTION % [access_token["access_token"], media_id]
          remote_resource_url = (WEIXIN_DOWNLOAD_URL + download_action)
          file_extension = ".amr"

          http = set_http(WEIXIN_DOWNLOAD_URL)
          request= Net::HTTP::Get.new(download_action)
          back_res = http.request(request)

          if back_res && !back_res[:errmsg].present?
            save_file(remote_resource_url, file_extension, msg_id)
          end
        end
      end
    end
  end

  def save_file(remote_resource_url, file_extension, msg_id)
    tmp_file = open(remote_resource_url) #打开直接下载链接
    filename = msg_id + file_extension  #临时文件不能取到扩展名
    weixin_resource = "/companies/%d/" % @company.root_path + "weixin_resource/"
    wx_full_resource = Rails.root.to_s + weixin_resource
    new_file_name = wx_full_resource + filename
    FileUtils.mkdir_p(wx_full_resource) unless Dir.exists?(wx_full_resource)
    File.open(new_file_name, "wb")  {|f| f.write tmp_file.read }
    if File.exist?(new_file_name)
      message_path = "/companies/%d/" % @company.id + "weixin_resource/" + filename #保存进数据库的路径
      get_client_message(message_path)
    end
  end

end