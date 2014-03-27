#encoding:utf-8
class AddressSettingsController < ApplicationController
  before_filter :has_sign?, :get_title
  def index
    @provinces = City.where(["parent_id=?", 0])
    @cities = City.where(["parent_id=?", @provinces[0].id]) if @provinces.any?
    @addresses = WorkAddress.paginate_by_sql(["select c1.name pname, c2.name cname, wa.id wid, wa.address address, wa.city_id city_id
        from cities c1 inner join cities c2 on c1.id=c2.parent_id
        inner join work_addresses wa on c2.id=wa.city_id
        where c1.parent_id=? and wa.company_id=? order by wa.updated_at desc", 0, @company.id],
      :per_page => 10, :page => params[:page] ||= 1)
  end

  def create
    WorkAddress.transaction do
      city_id = params[:new_address_select_city].to_i
      address = params[:new_addre]
      wa = WorkAddress.new(:address => address, :city_id => city_id, :company_id => @company.id)
      if wa.save
        flash[:notice] = "新建成功!"
      else
        flash[:notice] = "新建失败!"
      end
      redirect_to company_address_settings_path(@company)
    end
  end

  def edit
    wid = params[:id].to_i
    wa = WorkAddress.find_by_id_and_company_id(wid, @company.id)
    @status = 1
    if wa.nil?
      @status = 0
    else
      @wa = wa
      @provinces = City.where(["parent_id=?", 0])
      @addre_city = City.find_by_id(wa.city_id)
      @cities = City.where(["parent_id=?", @addre_city.parent_id])
    end
    respond_to do |f|
      f.js
    end
  end

  def update
    WorkAddress.transaction do
      wid = params[:id].to_i
      wa = WorkAddress.find_by_id_and_company_id(wid, @company.id)
      if wa.nil?
        flash[:notice] = "数据错误!"
      else
        hash = {:city_id => params[:edit_address_select_city].to_i, :address => params[:edit_addre]}
        if wa.update_attributes(hash)
          flash[:notice] = "编辑成功!"
        else
          flash[:notice] = "编辑失败!"
        end
      end
      redirect_to company_address_settings_path(@company)
    end
  end

  def destroy
    WorkAddress.transaction do
      wid = params[:id].to_i
      wa = WorkAddress.find_by_id_and_company_id(wid, @company.id)
      if wa.nil?
        flash[:notice] = "数据错误!"
      else
        if wa.destroy
          flash[:notice] = "删除成功!"
        else
          flash[:notice] = "删除失败!"
        end
      end
      redirect_to company_address_settings_path(@company)
    end
  end
  
  def search_citties
    pro_id = params[:pro_id].to_i
    @cities = City.select("id,name").where(["parent_id=?", pro_id])
    render :json => {:cities => @cities}
  end

  def get_title
    @title = "工作地址管理"
  end
  
end
