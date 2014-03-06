#encoding:utf-8
class Weixin::WeixinsController < ApplicationController
  before_filter :get_company_by_cweb  #根据cweb参数，获取对应的公司

  #用于处理相应服务号的请求以及一开始配置服务器时候的验证，post 或者 get
  def accept_token
    signature, timestamp, nonce, echostr, cweb = params[:signature], params[:timestamp], params[:nonce], params[:echostr], params[:cweb]
    tmp_encrypted_str = get_signature(cweb, timestamp, nonce)
    if request.request_method == "POST" && tmp_encrypted_str == signature
      if params[:xml][:MsgType] == "event" && params[:xml][:Event] == "subscribe"   #用户关注事件
        create_menu(cweb)  #创建自定义菜单
      elsif params[:xml][:MsgType] == "text"   #用户发送文字消息
        #存储消息并推送到ios端
        get_client_message
        client = Client.find_by_open_id_and_status(params[:xml][:FromUserName], Client::TYPES[:CONCERNED])
        if client
          message = "app_regist_link" #TODO
          message = "&lt;a href='#{MW_URL + message}?open_id=#{params[:xml][:FromUserName]}' &gt; 请点击登记您的信息&lt;/a&gt;"  #登记信息url
          xml = teplate_xml(message)
          render :xml => xml        #回复登记app的链接
        end
      elsif params[:xml][:MsgType] == "image" #用户发送图片
        save_image_or_voice_from_wx(cweb, "image")
        render :text => "ok"
      elsif params[:xml][:MsgType] == "voice" #用户发送语音
        save_image_or_voice_from_wx(cweb, "voice")
        render :text => "ok"
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
    if @site
      current_client =  Client.where("site_id=#{@site.id} and types = #{Client::TYPES[:ADMIN]}")[0]  #后台登陆人员
      client = Client.find_by_open_id_and_status(open_id, Client::STATUS[:valid])  #查询有效用户
      if @site.exist_app && client && current_client && client.update_attribute(:has_new_message,true)
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
              mess = Message.create!(:site_id => @site.id , :from_user => client.id ,:to_user => current_client.id ,
                :types => Message::TYPES[:weixin], :content => content,
                :status => Message::STATUS[:UNREAD], :msg_id => params[:xml][:MsgId],
                :message_type => msg_type_value, :message_path => wx_resource_url)
              if mess && (!@site.receive_status || !(@site.receive_status && @site.not_receive_start_at && @site.not_receive_end_at && time_now >= @site.not_receive_start_at.strftime("%H:%M") && time_now <= @site.not_receive_end_at.strftime("%H:%M")))
                #推送到IOS端
                APNS.host = 'gateway.sandbox.push.apple.com'
                APNS.pem  = File.join(Rails.root, 'config', 'CMR_Development.pem')
                APNS.port = 2195
                token = current_client.token
                if token
                  badge = Client.where(["site_id=? and types=? and has_new_message=?", @site.id, Client::TYPES[:CONCERNED],
                      Client::HAS_NEW_MESSAGE[:YES]]).length
                  content = "#{client.name}:#{mess.content}"
                  APNS.send_notification(token,:alert => content, :badge => badge, :sound => client.id)
                  recent_client = RecentlyClients.find_by_site_id_and_client_id(@site.id, client.id)
                  if recent_client
                    recent_client.update_attributes!(:content => mess.content)
                  else
                    RecentlyClients.create!(:site_id => @site.id, :client_id => client.id, :content => mess.content)
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

  
end