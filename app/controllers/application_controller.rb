#encoding: utf-8
class ApplicationController < ActionController::Base
  protect_from_forgery
  include ApplicationHelper
  include PositionsHelper
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
  def get_access_token
    app_id = @company.app_id
    app_secret = @company.app_secret
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

end
