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
      if params[:menu_types]
        temp_id, menu_types, file_path =  before_create_update
      else
        temp_id, menu_types = 0, Menu::TYPES[:nothing]
      end
      temp_id = temp_id || 0
      if params[:parent_id].to_i == 0   #建立一级菜单
        father_menus = Menu.where(["parent_id = ? and company_id = ?", params[:parent_id].to_i, @company.id]).length
        if father_menus >= 3
          flash[:notice] = "每个一级菜单最多只能保持3个!"
        else
          menu = Menu.new(:name => params[:menu_name], :temp_id => temp_id, :parent_id => params[:parent_id].to_i,
            :company_id => params[:company_id].to_i, :types => menu_types,
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
          flash[:notice] = "每个一级菜单的二级菜单最多只能保持5个!"
        else
          menu = Menu.new(:name => params[:menu_name], :temp_id => temp_id, :parent_id => params[:parent_id].to_i,
            :company_id => params[:company_id].to_i, :types => menu_types,
            :file_path => file_path.blank? ? nil : file_path)
          if menu.save
            flash[:notice] = "创建成功!"
          else
            flash[:notice] = "创建失败!"
          end
        end
      end
      redirect_to company_menus_path(@company)
    end
  end

  def update
    Menu.transaction do
      menu = Menu.find_by_id(params[:id].to_i)
      temp_id,menu_types,file_path =  before_create_update
      hash = {:parent_id => params[:parent_id].to_i, :name => params[:menu_name], :temp_id => temp_id || 0, :types => menu_types,
        :file_path => file_path.blank? ? nil : file_path}
      if menu.update_attributes(hash)
        flash[:notice] = "编辑成功"
        redirect_to company_menus_path(@company)
      else
        flash[:notice] = "编辑失败"
        redirect_to company_menus_path(@company)
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

  private
  def before_create_update
    menu_types = params[:menu_types]
    if menu_types.include?("company_profile")
      cp_arr = menu_types.split("_")
      cp_id = cp_arr[-1].to_i
      cp_new = cp_arr[0..1].join("_")
      temp_id = cp_id
      menu_types = Menu::TYPES[cp_new.to_sym]
      company_profile = CompanyProfile.find_by_id cp_id
      file_path = company_profile.file_path if company_profile
    elsif menu_types.include?("positions")
      pt_id = menu_types.split("_")[1].to_i
      menu_types = Menu::TYPES[menu_types.split("_")[0].to_sym]
      temp_id = pt_id
    elsif menu_types.to_i == Menu::TYPES[:outside_link]
      file_path = params[:outside_link]
    end
    [temp_id,menu_types,file_path]
  end
end
