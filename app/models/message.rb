#encoding: utf-8
class Message < ActiveRecord::Base
  require 'net/http'
  require "uri"
  require 'openssl'
  attr_protected :authenticate
  validates_uniqueness_of :msg_id, :allow_nil => true
  TYPES = {:phone => 0, :message => 1, :record => 2, :remind => 3, :weixin => 4} #0打电话，1信息，2记录，3提醒，4微信消息
  S_TYPES = {0 => "打电话", 1 => "短信", 2 => "记录", 3 => "提醒", 4 => "微信"}
  STATUS = {:READ => 1, :UNREAD => 0} #该信息0未读/未发，1已读/已发
  MSG_TYPE = {:text => 0, :image => 1, :voice => 2} #用户发来的消息类型  文字，图片，语音

  #发短信url
  MESSAGE_URL = "http://mt.yeion.com"
  USERNAME = "XCRJ"
  PASSWORD = "123456"

  
  def self.create_get_http(url,route)
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    if uri.port==443
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end
    request= Net::HTTP::Get.new(route)
    back_res =http.request(request)
    return JSON back_res.body
  end

  def self.send_message
    Message.transaction do
      message_clients = Message.find_by_sql("select  m.id id,m.content content,c.mobiephone mobile,m.site_id site_id,m.created_at created_at
        from messages m inner join clients c on m.to_user = c.id where  m.status = #{Message::STATUS[:READ]} and m.types = #{Message::TYPES[:remind]}")
      message_clients = message_clients.group_by { |message_client| message_client.site_id }
      reminds = Remind.find_all_by_site_id(message_clients.keys).group_by{|remind| remind.site_id}
      message_clients.each do |site_id, message_clients_arr|
        remind = reminds[site_id][0]
        message_clients_arr.each do |message_client|
          if remind.reseve_time.nil?
            sent_time = message_client.created_at + remind.days.to_i.days
            sent_time_str = sent_time.strftime("%Y-%m-%d")
          else
            sent_time_str = remind.reseve_time.strftime("%Y-%m-%d")
          end
          today = Time.now.strftime("%Y-%m-%d")
          if today.eql?(sent_time_str)
            contents = message_client.content
            content = ""
            content_splitleft = contents.split("[[")
            content_splitleft.each do |splitleft|
              if splitleft.include? "]]"
                splitright = splitleft.split("]]")[0]
                if(splitright.split("=")[0].eql?("选项"))
                  content += splitright.split("=")[1].split("-")[0]
                else
                  content += splitright.split("=")[1]
                end
                if splitleft.split("]]")[1]
                  content += splitleft.split("]]")[1]
                end
              else
                if splitleft
                  content += splitleft
                end
              end
            end
            mobilephone = message_client.mobile
            begin
              message_route = "/send.do?Account=#{Message::USERNAME}&Password=#{Message::PASSWORD}&Mobile=#{mobilephone}&Content=#{content}&Exno=0"
              create_get_http(Message::MESSAGE_URL, message_route)
            rescue
            end
            message = Message.find_by_id(message_client.id)
            message.update_attributes(:status => 1)
          end
        end
      end
    end
  end

end
