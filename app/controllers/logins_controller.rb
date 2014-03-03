#encoding: utf-8
class LoginsController < ApplicationController
  #登陆
  def index
    
  end

  #登陆验证
  def valid
    @comp_account = params[:comp_account]
    company = Company.find_by_company_account(@comp_account)
    if company.nil?
      flash[:notice] = "用户名不存在!"
      render "logins/index"
    else
      comp_password = params[:comp_password]
      if company.company_password != Digest::MD5.hexdigest(comp_password)
        flash[:notice] = "密码错误!"
        render "logins/index"
      else
        cookies[:company_id] = {:value =>Digest::MD5.hexdigest(company.id), :path => "/", :secure  => false}

      end
    end
  end

  #注册页面
  def regist

  end

  #注册验证
  def create
    @comp_name = params[:comp_name]
    @cweb = params[:comp_cweb]
    @has_app = params[:comp_has_app].to_i
    @app_account = params[:comp_app_count]
    @app_password = params[:comp_app_password]
    @comp_account = params[:comp_account]
    @comp_password = params[:comp_password]
    company = Company.new(:name => @comp_name, :cweb => @cweb, :has_app => @has_app==0 ? false : true,
      :status => Company::STATUS[:NORMAL],
      :app_account => @has_app==0 ? nil : @app_account, :app_password => @has_app==0 ? nil : Digest::MD5.hexdigest(@app_password),
      :company_account => @comp_account, :company_password => Digest::MD5.hexdigest(@comp_password))
    if company.save
      flash[:notice] = "注册成功!"
      render "logins/index"
    else
      flash[:notice] = company.errors.messages.values.flatten.join("\\n")
      render "logins/regist"
    end
  end
end
