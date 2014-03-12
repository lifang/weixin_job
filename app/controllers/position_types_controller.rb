#encoding: utf-8
class PositionTypesController < ApplicationController
  before_filter :has_sign?
    before_filter :get_title
  def index
    @position_types = @company.position_types
  end
  def create
    name = params[:name]
    @position_types = @company.position_types
    if PositionType.find_by_name_and_company_id(name,@company.id).blank?
      @position_type = @company.position_types.build
      @position_type.name = name
      if @position_type.save
        flash[:success] = "创建成功"
        redirect_to company_position_types_path(@company)
      else
        flash[:error] = "创建失败，#{@position_type.errors.messages.values.flatten.join("\\n")}"
        render 'index'
      end
    else
        flash[:error] = "创建失败，名称已经存在"
        render 'index'
    end
  end
  def destroy
    @position_type = PositionType.find_by_id(params[:id])
    if @position_type && @position_type.destroy
      flash[:success] = "删除成功"
      redirect_to company_position_types_path(@company)
    else
      flash[:error] = "删除失败，不存在职位类型"
      render 'index'
    end
  end

  def get_title
    @title = "职位类别"
  end
end