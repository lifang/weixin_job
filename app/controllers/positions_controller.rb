#encoding: utf-8
class PositionsController < ApplicationController   #招聘职位
  before_filter :get_company

  PerPage = 8
  def index
    @positions = @company.positions
  end

  def edit

  end

  def update

  end
  
  def new
    admin = Company.client
    @position = Position.new
    @positions = @company.positions.paginate(page:params[:page],per_page: PerPage)
  end

  def create
    id = params[:positions][:id]
    if id == ""
      name = params[:positions][:name]
      description = params[:positions][:description]
      @position = Position.new
      @position.name = name
      @position.description = description
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
    @position = Position.find_by_id(id)
    if @position && @position.update_attributes(name:name,description:description)
      flash[:success] = "更新成功！"
      redirect_to company_positions_path(@company)
    else
      flash[:error] = "更新失败！职位不存在！"
      render 'new'
    end
  end

  def release   #发布

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
