class ApplicationController < ActionController::Base
  protect_from_forgery

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

end
