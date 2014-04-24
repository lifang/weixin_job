#encoding: utf-8
class MenusController < ApplicationController   #菜单
  before_filter :has_sign?
  before_filter :get_title
  def index
    @resume_tmp = ResumeTemplate.find_by_company_id(@company.id)
    @positions = Position.where(["(status =1 or status = 2) and company_id =?", @company.id])
    time = Time.now.prev_month
    @newest_positions = []
    @positions.each do |position|
      if position.created_at >= time
        @newest_positions << position
      end
    end
    @position_types = PositionType.where(["company_id = ?", @company.id])
    @comp_profiles = CompanyProfile.select("id,title,file_path").where(["company_id = ?", @company.id])
    menus = Menu.where(["company_id = ?", @company.id]).group_by{|m| m.parent_id.to_s}
    @father_menus = menus["0"]
    @child_menus = menus.except("0")
  end

  def create
    Menu.transaction do
      temp_id = params[:temp_id].nil? || params[:temp_id]=="" ? Menu::NO_TEMP : params[:temp_id].to_i
      types = params[:menu_type].nil? || params[:menu_type]=="" ? Menu::TYPES[:no_type] : params[:menu_type].to_i
      file_path = params[:file_path]
      if types == 0 #选择的是资讯
        company_profile = CompanyProfile.find_by_id temp_id
        file_path = company_profile.file_path if company_profile #获取对应资讯的file_path
      end
      if params[:parent_id].to_i == 0   #建立一级菜单
        father_menus = Menu.where(["parent_id = ? and company_id = ?", params[:parent_id].to_i, @company.id]).length
        if father_menus >= 3
          flash[:notice] = "每个一级菜单最多只能保持3个!"
        else
          menu = Menu.new(:name => params[:menu_name], :temp_id => temp_id, :parent_id => params[:parent_id].to_i,
            :company_id => params[:company_id].to_i, :types => types,
            :file_path => file_path.blank? ? nil : file_path)
          if menu.save
            flash[:notice] = "创建成功!"
          else
            flash[:notice] = "创建失败!"
          end
        end
      else  #建立二级菜单
        child_menus = Menu.where(["parent_id = ? and company_id = ?", params[:parent_id].to_i, @company.id]).length
        if child_menus >= 5
          flash[:notice] = "每个一级菜单的二级菜单最多只能保持3个!"
        else
          menu = Menu.new(:name => params[:menu_name], :temp_id => temp_id, :parent_id => params[:parent_id].to_i,
            :company_id => params[:company_id].to_i, :types => types,
            :file_path => file_path.blank? ? nil : file_path)
          if menu.save
            flash[:notice] = "创建成功!"
          else
            flash[:notice] = "创建失败!"
          end
        end
      end
    end
  end

  def update
    Menu.transaction do
      menu = Menu.find_by_id(params[:id].to_i)
      temp_id = params[:temp_id].nil? || params[:temp_id]=="" ? Menu::NO_TEMP : params[:temp_id].to_i
      types = params[:menu_type].nil? || params[:menu_type]=="" ? Menu::TYPES[:no_type] : params[:menu_type].to_i
      file_path = params[:file_path]
      if types == 0  #选择的是资讯
        company_profile = CompanyProfile.find_by_id temp_id
        file_path = company_profile.file_path if company_profile #获取对应资讯的file_path
      end
      hash = {:parent_id => params[:parent_id].to_i, :name => params[:menu_name], :temp_id => temp_id, :types => types,
        :file_path => file_path.blank? ? nil : file_path}
      if menu.update_attributes(hash)
        @status = 1
      else
        @status = 0
      end
    end
  end

  def show_edit_menu
    @comp_profiles = CompanyProfile.select("id,title,file_path").where(["company_id = ?", @company.id])
    @menu = Menu.find_by_id(params[:id])
    @position_types = PositionType.where(["company_id = ?", @company.id])
  end

  def destroy
    Menu.transaction do
      menu = Menu.find_by_id(params[:id].to_i)
      if menu
        if menu.parent_id != 0
          menu.destroy
          flash[:notice] = "删除成功!"
        else
          Menu.delete_all(["parent_id = ?", menu.id])
          menu.destroy
          flash[:notice] = "删除成功!"
        end
      else
        flash[:notice] = "数据错误!"
      end
      redirect_to company_menus_path(@company)
    end
  end

  def get_title
    @title = "菜单"
  end
end
