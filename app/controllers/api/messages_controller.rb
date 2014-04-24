#encoding:utf-8
class Api::MessagesController < ApplicationController
  skip_before_filter :authenticate_user!
  #创建记录
  def make_record
    Message.transaction do
      status = 0
      msg = ""
      from_user = params[:from_user].to_i
      to_user = params[:to_user].to_i
      content = params[:content]
      types = params[:types].to_i
      company_id = params[:site_id].to_i
      message = Message.new(:company_id => company_id, :from_user => from_user, :to_user => to_user, :types => types,
        :content => content, :status => Message::STATUS[:READ], :msg_id => nil)
      if message.save
        status = 1
        msg = "保存成功!"
        mess = {:id => message.id, :from_user => message.from_user, :to_user => message.to_user, :types => message.types,
          :content => message.content, :status => message.status ? 0 : 1,
          :date => message.created_at.nil? ? nil : message.created_at.strftime("%Y-%m-%d %H:%M"),
          :message_type => message.message_type, :message_path => Weixin::MW_URL + message.message_path.to_s,
          :voice_type => message.message_type == Message::MSG_TYPE[:voice] ? (mess.message_path && mess.message_path.include?(".mp3") ? "mp3" : "amr") : nil
        }
        if types == Message::TYPES[:remind] #如果是提醒，则要将has_new_record设为1
          person = Client.find_by_id(to_user)
          person.update_attribute("has_new_record", true) if person
        end
        recent_client = RecentlyClients.find_by_company_id_and_client_id(company_id, to_user)
        if recent_client.nil?
          RecentlyClients.create(:company_id => company_id, :client_id => to_user, :content => content)
        else
          recent_client.update_attribute("content", content)
        end
      else
        msg = "保存失败!"
      end
      render :json => {:status => status, :msg => msg, :return_object => {:message => mess}}
    end
  end

  #编辑记录
  def edit_record
    Message.transaction do
      type = params[:type].to_i #0编辑，1删除
      status = 0
      msg = ""
      m_id = params[:message_id].to_i
      message = Message.find_by_id(m_id)
      has_remind = 0
      if message
        recent_client = RecentlyClients.find_by_company_id_and_client_id(message.company_id, message.to_user)
        if type == 0 #编辑该消息
          content = params[:content]
          if content && message.update_attribute("content", content)
            status = 1
            msg = "编辑成功!"
            mess = {:id => message.id, :from_user => message.from_user, :to_user => message.to_user, :types => message.types,
              :content => message.content, :status => message.status ? 0 : 1,
              :date => message.created_at.nil? ? nil : message.created_at.strftime("%Y-%m-%d %H:%M")}
            if recent_client.nil?
              RecentlyClients.create(:company_id => message.company_id, :client_id => message.to_user, :content => content)
            else
              recent_client.update_attribute("content", content)
            end
          end
        elsif type == 1 #删除该消息
          from_user = message.from_user
          to_user = message.to_user
          company_id = message.company_id
          m_type = message.types
          message.destroy
          status = 1
          msg = "删除成功!"
          #删除后找到该用户的上一条消息
          previous_mess = Message.find_by_sql(["select * from messages m where m.company_id=? and m.from_user=? and m.to_user=?
            order by m.created_at desc", company_id, from_user, to_user]).first
          if previous_mess.nil?
            if recent_client.nil?
              RecentlyClients.create(:company_id => company_id, :client_id => to_user, :content => "")
            else
              recent_client.update_attribute("content","")
            end
          else
            if recent_client.nil?
              RecentlyClients.create(:company_id => company_id, :client_id => to_user, :content => previous_mess.content)
            else
              recent_client.update_attribute("content",previous_mess.content)
            end
            #pm = previous_mess.merge({:status => previous_mess.status ? 0 : 1})
            pm = {:id => previous_mess.id, :company_id => previous_mess.company_id, :from_user => previous_mess.from_user,
              :to_user => previous_mess.to_user, :types => previous_mess.types, :content => previous_mess.content,
              :status => previous_mess.status ? 0 : 1, :created_at => previous_mess.created_at,
              :updated_at => previous_mess.updated_at, :msg_id => previous_mess.msg_id, :message_type => previous_mess.message_type,
              :message_path => Weixin::MW_URL + previous_mess.message_path.to_s,
              :voice_type => mess.message_type == Message::MSG_TYPE[:voice] ? (mess.message_path && mess.message_path.include?(".mp3") ? "mp3" : "amr") : nil
            }
          end

          if message.types == Message::TYPES[:remind]
            left_messages = Message.where(["company_id=? and from_user=? and to_user=? and types=? and status=?", company_id, from_user,
                to_user, Message::TYPES[:remind], Message::STATUS[:READ]]).length
            if left_messages > 0  #有剩余未读提醒
              has_remind = 1
            else
              client = Client.find_by_id(to_user)
              client.update_attribute("has_new_record", false) if client
            end
          end

        end
      else
        msg = "数据错误!"
      end
      render :json => {:status => status, :msg => msg, :return_object => {:message => type == 1 ? {} : mess,
          :type => message.nil? ? nil : m_type, :has_remind => has_remind, :last_message => pm}}
    end
  end

  #公众号 主动发消息 给用户  现在只支持文本
  def send_message_to_user
    #params[:site_id], params[:msg_type], params[:content], params[:client_id],站点名称，发送消息的类型(text,image,voice)，发送的内容(类型是text时)， 接收信息的open_id
    status, msg = [1, ""]
    company_id, msg_type, content, receive_client_id = params[:site_id], params[:msg_type], params[:content], params[:client_id]
    current_client =  Client.where("company_id=#{company_id} and types = #{Client::TYPES[:ADMIN]}")[0] if company_id  #后台登陆人员
    receive_client = Client.find_by_id_and_status(receive_client_id, Client::STATUS[:valid]) if receive_client_id   #查询有效用户
    open_id = receive_client.open_id if receive_client  
    msg_type_value = Message::MSG_TYPE[msg_type.to_sym] if msg_type
    unless msg_type == "text"
      content = msg_type_value == 1 ? "图片" : "语音"
    end
    content_hash = get_content_hash_by_type(open_id, msg_type, content)
    if company_id.present? && current_client && receive_client && open_id
      company = Company.find_by_id(company_id)
      if company
        if company.service_account? &&  company.app_service_certificate #公众号是认证服务号
          access_token = get_access_token(company)
          if access_token and access_token["access_token"]
            send_message_action = "/cgi-bin/message/custom/send?access_token=#{access_token["access_token"]}"
            response = create_post_http(WEIXIN_OPEN_URL ,send_message_action, content_hash)
            if response
              if response["errcode"] == 0
                msg = "发送成功"
                mess = Message.create!(:company_id => company_id, :from_user => current_client.id ,:to_user => receive_client.id ,
                  :types => Message::TYPES[:weixin], :content => content,
                  :status => Message::STATUS[:READ], :msg_id => nil,
                  :message_type => msg_type_value)
                message = {:id => mess.id, :from_user => mess.from_user, :to_user => mess.to_user, :types => mess.types,
                  :content => mess.content, :status => mess.status ? 0 : 1,
                  :date => mess.created_at.nil? ? nil : mess.created_at.strftime("%Y-%m-%d %H:%M"), :message_type => mess.message_type,
                  :message_path => Weixin::MW_URL + mess.message_path.to_s,
                  :voice_type => mess.message_type == Message::MSG_TYPE[:voice] ? (mess.message_path && mess.message_path.include?(".mp3") ? "mp3" : "amr") : nil
                  }
                unless mess
                  status = 0
                  msg += "保存失败"
                end
              elsif response["errcode"] == 45015
                status = 0
                msg = "此用户超过48小时未与您互动，发送消息失败"
              else
                status = 0
                msg = "发送失败"
              end
            else
              status = 0
              msg = "请求超时"
            end
          else
            status = 0
            msg = "此公众号没有权限主动发送信息，请先认证！"
          end
        else   #公众号是订阅号 或者未认证的服务号
          message = send_message_hack(company, content, receive_client_id, current_client, receive_client, msg_type_value)
          if message
            msg = "发送成功"
          else
            status = 0
            msg = "此用户超过48小时未与您互动，发送消息失败"
          end
        end
      else
        status = 0
        msg = "该网站未绑定微信公众号"
      end
     
    else
      status = 0
      msg = "缺少参数或者用户无效，等待用户主动与您联系"
    end

    render :json => {:status => status, :message => msg, :return_object => {:message => status == 0 ? nil : message}}
  end

  #订阅号或者未认证的服务号  发送信息hack
  def send_message_hack(company, content, receive_client_id, current_client, receive_client, msg_type_value)
    msg = send_single_message(company, content, receive_client_id)
    if msg == "success"
      mess = Message.create!(:company_id => company.id, :from_user => current_client.id ,:to_user => receive_client.id ,
        :types => Message::TYPES[:weixin], :content => content,
        :status => Message::STATUS[:READ], :msg_id => nil,
        :message_type => msg_type_value)
      message = {:id => mess.id, :from_user => mess.from_user, :to_user => mess.to_user, :types => mess.types,
        :content => mess.content, :status => mess.status ? 0 : 1,
        :date => mess.created_at.nil? ? nil : mess.created_at.strftime("%Y-%m-%d %H:%M"), :message_type => mess.message_type,
        :message_path => Weixin::MW_URL + mess.message_path.to_s,
        :voice_type => mess.message_type == Message::MSG_TYPE[:voice] ? (mess.message_path && mess.message_path.include?(".mp3") ? "mp3" : "amr") : nil}
    end
    message
  end
end