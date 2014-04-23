#encoding: utf-8
class ApplicationController < ActionController::Base
  protect_from_forgery
  include ApplicationHelper
  include PositionsHelper
  include MicroMessageHelper
  require 'net/http'
  require "uri"
  require 'openssl'


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
    content_hash_json = content_hash.to_json
    content_hash_json.gsub!(/\\u([0-9a-z]{4})/) {|s| [$1.to_i(16)].pack("U")}
    content_hash_json
  end

 


end
