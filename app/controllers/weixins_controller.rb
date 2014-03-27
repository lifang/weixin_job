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
        client = Client.find_by_open_id(open_id)

        if params[:xml][:MsgType] == "event" && params[:xml][:Event] == "subscribe"   #用户关注事件
          return_app_regist_link  #返回app登记链接
          save_client_info(open_id, @company) #新建client记录，保存头像，nick_name, faker_id, open_id
        
          create_menu if @company.app_id.present? && @company.app_secret.present?   #创建自定义菜单
        elsif params[:xml][:MsgType] == "text"   #用户发送文字消息
       
          #完善用户信息
          complete_client_info(@company, client, open_id)  #save open_id
          #存储消息并推送到ios端
          get_client_message
          
          if client && client.html_content.blank? #返回app登记链接
            return_app_regist_link
          else
            render :text => "ok"
          end
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

  def complete_client_info(company, client, open_id)
    unless company.service_account? && company.app_service_certificate
      if client
        if client.faker_id.blank?  #有open_id 没有 faker_id
          faker_id = get_voice_path_or_faker_id(company, "faker_id")
          client.update_attribute(:faker_id, faker_id)
        end
      else
        faker_id = get_voice_path_or_faker_id(company, "faker_id")
        client = company.clients.where(:types => Client::TYPES[:CONCERNED], :faker_id => faker_id)[0]
        if client  # 有faker_id 没有 open_id  是老用户  同步来的
          client.update_attribute(:open_id, open_id)
        else
          #save_client_info(open_id, @company) #新建client记录，保存头像，faker_id, open_id
        end
      end
    end
  end

end