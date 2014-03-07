#encoding: utf-8
class PositionsController < ApplicationController   #招聘职位
  before_filter :get_company

  PerPage = 8

  def index
    @position_types = @company.position_types || []
    @positions = @company.positions.paginate(page:params[:page],per_page: PerPage*2,conditions:"status =1 or status = 2")
  end

  def edit

  end
  
  def new
    @position_types = @company.position_types || []
    @position = Position.new
    @positions = @company.positions.paginate(page:params[:page],per_page: PerPage,conditions:"status =1 or status = 2")
  end

  def create
    id = params[:positions][:id]
    if id == ""
      types = params[:positions][:types]
      name = params[:positions][:name]
      description = params[:positions][:description]
      @position = Position.new
      @position.position_type_id = types
      @position.name = name
      @position.description = description
      @position.status = Position::STATU[:UNRELEASE]
      @position.company_id = @company.id
      if @position.save
        flash[:success] = "新建成功！"
        redirect_to company_positions_path(@company)
      else
        flash[:error] = "新建失败！职位已经存在！"
        render 'new'
      end
    else
      update
    end
  end
  def update
    id = params[:positions][:id]
    name = params[:positions][:name]
    description = params[:positions][:description]
    types = params[:positions][:types]
    @position = Position.find_by_id(id)
    if @position && @position.update_attributes(name:name,description:description,position_type_id:types)
      flash[:success] = "更新成功！"
      redirect_to company_positions_path(@company)
    else
      flash[:error] = "更新失败！职位不存在！"
      render 'new'
    end
  end

  def search_position
    @position_types = @company.position_types || []
    p = params[:position]
    @positions = Position.where("company_id=#{@company.id} and name like ? and (status =1 or status = 2)","%#{p}%")||[]
    render 'index'
  end

  def release   #发布
     @position = Position.find_by_id(params[:id])
     if @position && @position.update_attribute(:status,Position::STATU[:RELEASED])
       flash[:success] = '发布成功'
       redirect_to company_positions_path(@company)
     else
       flash[:error] = '发布失败，不存在职位！'
       render 'index'
     end
  end

  def destroy
    @position = Position.find_by_id(params[:id])
    if @position && @position.destroy
      flash[:success] = "删除成功！"
      redirect_to company_positions_path(@company)
    else
      flash[:error] = "删除失败！请刷新页面"
      render 'index'
    end
  end
end
