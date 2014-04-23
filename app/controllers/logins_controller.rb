#encoding: utf-8
class LoginsController < ApplicationController
  layout :false
  #登陆
  def index
    
  end

  #登陆验证
  def valid
    comp_account = params[:comp_account]
    company = Company.find_by_company_account(comp_account)
    if company.nil?
      flash[:notice] = "用户名不存在!"
      redirect_to logins_path
    else
      comp_password = params[:comp_password]
      if company.company_password != Digest::MD5.hexdigest(comp_password)
        flash[:notice] = "密码错误!"
        redirect_to logins_path
      else
        cookies[:company_id] = {:value =>Digest::MD5.hexdigest("#{company.id}"), :path => "/", :secure  => false}
        cookies[:company_account] = {:value =>company.company_account, :path => "/", :secure  => false}
        redirect_to "/companies/show?company_id=#{company.id}"
      end
    end
  end

  #注册页面
  def regist
    @company = Company.new
  end

  #注册验证
  def create
    comp_name = params[:comp_name]
    comp_account = params[:comp_account]
    comp_password = params[:comp_password]
    valid_comp = Company.find_by_name(comp_name)
    if valid_comp
      flash[:notice] = "注册失败,已有同名的公司!"
      render "logins/regist"
    else
      valid_comp_account = Company.find_by_company_account(comp_account)
      if valid_comp_account
        flash[:notice] = "注册失败,已有同名的账号!"
        render "logins/regist"
      else
        Company.transaction do
          company = Company.new(:name => comp_name, :status => Company::STATUS[:NORMAL],:company_account => comp_account,
            :company_password => Digest::MD5.hexdigest(comp_password), :app_type => Company::APP_TYPE[:SUBSCRIPTION])
          if company.save
            resume_hash = {"headimage" => {"name" => "上传头像", "url" => ""},
              "message_1" => {"name" => "姓名"}, "message_2" => {"name" => "联系电话"}, "message_3" => {"name" => "邮箱"},
              "message_4" => {"name" => "地址"}}
            resume = ResumeTemplate.new(:html_content => resume_hash, :company_id => company.id)
            if resume.save
              ResumeTemplate.get_html(resume)
            end
            menu1 = Menu.create(name:"我的...",
              temp_id:0,
              parent_id:0,
              company_id:company.id,
              types:3)
            menu2 = Menu.create(name:"职位",
              temp_id:0,
              parent_id:0,
              company_id:company.id,
              types:3)
            
            Menu.create(name:"我的简历",
              temp_id:0,
              parent_id: menu1.id,
              company_id:company.id,
              types:2)
            Menu.create(
              name:"我的求职",
              temp_id:Menu::TEMP_TYPES[:my_jobs],
              parent_id: menu1.id,
              company_id:company.id,
              types:3)
            Menu.create(name:"我的推荐",
              temp_id:Menu::TEMP_TYPES[:my_recommend],
              parent_id: menu1.id,
              company_id:company.id,
              types:3)
            Menu.create(name:"全部职位",
              temp_id:Menu::TEMP_TYPES[:search_job],
              parent_id: menu2.id,
              company_id:company.id,
              types:2)
            Menu.create(name:"最新职位",
              temp_id: Menu::TEMP_TYPES[:newest],
              parent_id: menu2.id,
              company_id:company.id,
              types:2)
            flash[:notice] = "注册成功!"
            redirect_to logins_path
          else
            flash[:notice] = company.errors.messages.values.flatten.join("\\n")
            render "logins/regist"
          end
        end
      end
    end
  end

  #登出
  def sign_out
    cookies.delete(:company_account)
    cookies.delete(:company_id)
    flash[:notice] = "注销成功!"
    redirect_to logins_path
  end
  
end
