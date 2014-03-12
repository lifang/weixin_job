#encoding: utf-8
class PositionsController < ApplicationController   #招聘职位
  before_filter :has_sign?
  before_filter :get_company,only:[:show,:send_resume]
  skip_before_filter :has_sign? ,only:[:show,:send_resume]
  before_filter :get_title,:get_position_type,:get_positions
  
  PerPage = 8

  def index
    @positions = @company.positions.paginate(page:params[:page],per_page: PerPage*2,conditions:"status =1 or status = 2")
  end

  def edit

  end
  
  def new
    @position = Position.new
    @positions = @company.positions.paginate(page:params[:page],per_page: PerPage,conditions:"status =1 or status = 2")
  end

  def edit
    @position = Position.find_by_id(params[:id])
    @positions = @company.positions.paginate(page:params[:page],per_page: PerPage,conditions:"status =1 or status = 2")
    render 'new'
  end

  def create
    id = params[:positions][:id]
    if id == ""
      types = params[:positions][:types]
      name = params[:positions][:name].strip
      description = params[:positions][:description]
      @position = Position.new
      @position.position_type_id = types
      @position.name = name
      @position.description = description
      @position.status = Position::STATUS[:UNRELEASE]
      @position.company_id = @company.id
      if Position.find_by_name_and_company_id(name,@company.id).blank? && @position.save
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
    name = params[:positions][:name].strip
    description = params[:positions][:description]
    types = params[:positions][:types]
    @position = Position.find_by_id(id)
    if @position&& @position.update_attributes(name:name,description:description,position_type_id:types)
      flash[:success] = "更新成功！"
      redirect_to company_positions_path(@company)
    else
      flash[:error] = "更新失败！职位不存在！"
      render 'new'
    end

  end

  def show
    
    @position_types = @company.position_types || []
    @position = Position.find_by_id(params[:id])
    @client_resume = ClientResume.find_by_open_id_and_company_id(params[:secret_key],@company.id)
    if @position.blank?
      render 'public/404'
    else
      render layout:false
    end
    
  end
  def send_resume
    if params[:client_resume_id].blank?
      @message = "投递失败！请登记简历"
    else
      @delivery_resume_record = DeliveryResumeRecord.create(company_id:@company.id,
        position_id:params[:position_id],
        client_resume_id:params[:client_resume_id])
      @message = "投递成功！"
    end
   
    render 'success',layout:false
  end
  
  def search_position
    p = params[:position]
    @positions = Position.where("company_id=#{@company.id} and name like ? and (status =1 or status = 2)","%#{p}%")||[]
    render 'index'
  end

  def release   #发布
    @position = Position.find_by_id(params[:id])
    if @position && @position.update_attribute(:status,Position::STATUS[:RELEASED])
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
  def send_resumn

  end
  def get_positions
    @positions = @company.positions.paginate(page:params[:page],per_page: PerPage*2,conditions:"status =1 or status = 2")
  end
  def get_position_type
    @position_types = @company.position_types || []
  end
  def get_title
    @title = "招聘职位"
  end
  def get_company
    @company = Company.find_by_id(params[:company_id])
  end

end
