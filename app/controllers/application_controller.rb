#encoding: utf-8
class ApplicationController < ActionController::Base
  protect_from_forgery
  include ApplicationHelper
  include PositionsHelper

  def has_sign?
    c_id = params[:company_id].to_i
    if cookies[:company_account].nil? || cookies[:company_id].nil? || cookies[:company_id] != Digest::MD5.hexdigest(c_id)
      cookies.delete(:company_account)
      cookies.delete(:company_id)
      flash[:notice] = "请先登陆!"
      redirect_to logins_path
    else
      @company = Company.find_by_id(c_id)
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

end
