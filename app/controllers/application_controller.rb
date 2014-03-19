#encoding: utf-8
class ApplicationController < ActionController::Base
  protect_from_forgery
  include ApplicationHelper
  include PositionsHelper
  require 'net/http'
  require "uri"
  require 'openssl'

  Weixin_resource = "/public/companies/%d/weixin_resource/"

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

  #获取朋友faker_id
  def get_new_friend_fakeid(wx_cookie, token)
    page_contact_action = WEIXIN_CONTACT_LIST_ACTION % [10, token, 0]  #10 代表每页个数， 0代表第一页
    http = set_http(WEIXIN_URL)
    new_friend_faker_id = nil
    http.request_get(page_contact_action,{"Cookie" => wx_cookie} ) {|response|
      f_id = Regexp.new('"id":([0-9]{4,20})')
      #TODO  nickname
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
    msg = send_message_request(company,content, gzh_client, to_faker_id, wx_token,wx_cookie)
    msg
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
      res =  JSON response.body
      if res["base_resp"]["ret"]== 0
        msg = "success"
      else #数据库的token超时，重新登录
        login_info = login_to_weixin(company) 
        if login_info.present?
          wx_token, wx_cookie = login_info

          # gzh_client.update_attributes(:wx_login_token => wx_token, :wx_cookie => wx_cookie) #更新公众号faker_id
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


  #根据open_id和token，保存用户的头像信息
  def get_user_basic_info(open_id, company)
    access_token = get_access_token(company)
    user_avatar_url = nil
    if access_token && access_token["access_token"]
      action = GET_USER_INFO_ACTION % [access_token["access_token"], open_id]
      user_info = create_get_http(WEIXIN_OPEN_URL, action)
      if user_info && user_info["subscribe"]==1
        user_avatar_url = user_info["headimgurl"]
      end
    end
    user_avatar_url
  end

end
