#encoding: utf-8
class ResumesController < ApplicationController   #简历模板
  before_filter :get_title
  before_filter :has_sign?,:get_company
  def index
    #@company = Company.find_by_id(params[:company_id].to_i)
    resume_temp = ResumeTemplate.find_by_company_id(@company.id)
    #@cr = ClientResume.find_by_id(12)
    if resume_temp
      @resume_temp = resume_temp
    else
      @resume_temp = @company.resume_templates.create
    end
  end

  def add_form_item
    @name = params[:name] #message_div
    @title_name = params[:title_name] #message_24
    @item_tile = params[:item_title]
    if @name == "radio_div" || @name=="check_box_div" || @name=="select_div" || @name=="add_tag_div"
      @options = params[:options]
    end
    respond_to do |f|
      f.js
    end
  end

  def update
    tags_hash = params[:tags]
    company = Company.find_by_id(params[:company_id].to_i)
    resume_temp = ResumeTemplate.find_by_id(params[:id].to_i)
    ResumeTemplate.transaction do
      resume_temp.update_attribute("html_content", tags_hash)
      flash[:notice] = "模板编辑成功!"
      ResumeTemplate.get_html(resume_temp)
      redirect_to company_resumes_path(company)
    end
  end

  def newest_resumes
    @title+="-最新简历"
    @status = DeliveryResumeRecord::STATUS[:newest]
    @positions = @company.positions.where(" status = 2")
    @positions_and_resumes = Position.select("drr.id,positions.name,
             cr.html_content_datas,
             drr.created_at,
             drr.updated_at,
             drr.status,
             drr.audition_time,
             drr.audition_addr,
             drr.remark").
      joins("inner join delivery_resume_records drr on drr.position_id = positions.id").
      joins("inner join client_resumes cr on drr.client_resume_id = cr.id").
      where(["drr.status= ? and drr.company_id= ?",DeliveryResumeRecord::STATUS[:newest],@company.id])
  end

  def audition_resume
    @title+="-面试简历"
    @status = DeliveryResumeRecord::STATUS[:audition]
    @positions = @company.positions.where(" status = 2")
    @positions_and_resumes = Position.select("drr.id,positions.name,
             cr.html_content_datas,
             drr.created_at,
             drr.updated_at,
             drr.status,
             drr.audition_time,
             drr.audition_addr,
             drr.remark").
      joins("inner join delivery_resume_records drr on drr.position_id = positions.id").
      joins("inner join client_resumes cr on drr.client_resume_id = cr.id").
      where(["drr.status= ? and drr.company_id= ?",DeliveryResumeRecord::STATUS[:audition],@company.id])
  end
  def refuse_resume
    @title+="-面试简历"
    @status = DeliveryResumeRecord::STATUS[:refuse]
    @positions = @company.positions.where(" status = 2")
    @positions_and_resumes = Position.select("drr.id,positions.name,
             cr.html_content_datas,
             drr.created_at,
             drr.updated_at,
             drr.status,
             drr.audition_time,
             drr.audition_addr,
             drr.remark").
      joins("inner join delivery_resume_records drr on drr.position_id = positions.id").
      joins("inner join client_resumes cr on drr.client_resume_id = cr.id").
      where(["drr.status= ? and drr.company_id= ?",DeliveryResumeRecord::STATUS[:refuse],@company.id])
  end
  
  def pass_resume
    @title+="-面试简历"
    @status = DeliveryResumeRecord::STATUS[:pass]
    @positions = @company.positions.where(" status = 2")
    @positions_and_resumes = Position.select("drr.id,positions.name,
             cr.html_content_datas,
             drr.created_at,
             drr.updated_at,
             drr.status,
             drr.audition_time,
             drr.audition_addr,
             drr.remark").
      joins("inner join delivery_resume_records drr on drr.position_id = positions.id").
      joins("inner join client_resumes cr on drr.client_resume_id = cr.id").
      where(["drr.status= ? and drr.company_id= ?",DeliveryResumeRecord::STATUS[:pass],@company.id])
  end

  def deal_audition
    positions_and_resumes = DeliveryResumeRecord.find_by_id(params[:id])
    audition_time = params[:audition_time]
    audition_addr = params[:audition_addr]
    if positions_and_resumes
      positions_and_resumes.update_attributes(audition_time: audition_time,
        audition_addr: audition_addr,
        status: DeliveryResumeRecord::STATUS[:audition])
      redirect_to newest_resumes_company_resumes_path(@company,params[:id])
    else
      render 'newest'
    end
      
  end

  def choice_position
    status = params[:status].to_i
    postion_id = params[:postion_id]
    start_time = params[:start]
    end_time = params[:end]
    p 11111111111,status
    case status
    when DeliveryResumeRecord::STATUS[:newest]
      p 12321123123123
      get_positions_and_resumes postion_id,start_time,end_time
      render 'newest_resumes'
    when DeliveryResumeRecord::STATUS[:refuse]
    when DeliveryResumeRecord::STATUS[:audition]
    when DeliveryResumeRecord::STATUS[:pass]

    end
  end

  def change_status
    positions_and_resumes = DeliveryResumeRecord.find_by_id(params[:id])
    if positions_and_resumes && positions_and_resumes.update_attribute(:status,params[:status])
      render text:1
    else
      render text:0
    end
  end

  private
  def get_positions_and_resumes position_id,start_time,end_time
    @title+="-最新简历"
    @status = DeliveryResumeRecord::STATUS[:newest]
    @positions = @company.positions.where("status = 2")
    @positions_and_resumes = Position.select("drr.id,positions.id position_id,positions.name,
             cr.html_content_datas,
             drr.created_at,
             drr.updated_at,
             drr.status,
             drr.audition_time,
             drr.audition_addr,
             drr.remark").
      joins("inner join delivery_resume_records drr on drr.position_id = positions.id").
      joins("inner join client_resumes cr on drr.client_resume_id = cr.id").
      where(["drr.status= ? and drr.created_at >= ? and drr.created_at <= ? and positions.id = ?",DeliveryResumeRecord::STATUS[:newest],start_time,end_time,position_id ])
  end
  def get_title
    @title = "简历"
  end
  def get_company
    @company = Company.find_by_id(params[:company_id].to_i)
  end
end
