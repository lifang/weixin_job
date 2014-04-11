#encoding: utf-8
class ResumesController < ApplicationController   #简历模板
  before_filter :get_title
  before_filter :has_sign?,:get_company
  PerPage = 8
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
    get_positions_and_resumes_record "-最新简历",DeliveryResumeRecord::STATUS[:newest]
  end

  def audition_resume
    get_positions_and_resumes_record "-面试简历",DeliveryResumeRecord::STATUS[:audition]
  end
  def refuse_resume
    get_positions_and_resumes_record "-拒绝简历",DeliveryResumeRecord::STATUS[:refuse]
  end
  
  def pass_resume
    get_positions_and_resumes_record  "-入职简历",DeliveryResumeRecord::STATUS[:pass]
  end

  def get_positions_and_resumes_record msg,status
    @title+=msg
    @status = status
    @positions = @company.positions.where(" status = 2")
    @positions_and_resumes = ClientResume.
      where(["drr.status= ? and drr.company_id= ?",status,@company.id]).
      joins("inner join delivery_resume_records drr on drr.client_resume_id = client_resumes.id").
      joins("inner join positions p on drr.position_id = p.id ").
      select("drr.id,p.name,
             p.id position_id,
             client_resumes.id client_resume_id,
             client_resumes.html_content_datas,
             client_resumes.clint_name,
             client_resumes.client_phone,
             drr.created_at,
             drr.updated_at,
             drr.status,
             drr.audition_time,
             drr.audition_addr,
             drr.remark,
             drr.join_time,
             drr.join_addr,
             drr.join_remark").paginate(page: params[:page],per_page:PerPage)
      
  end

  def deal_audition
    positions_and_resumes = DeliveryResumeRecord.find_by_id(params[:id])
    audition_time = params[:audition_time]
    audition_addr = params[:audition_addr]
    if positions_and_resumes
      positions_and_resumes.update_attributes(audition_time: audition_time,
        audition_addr: audition_addr,
        status: DeliveryResumeRecord::STATUS[:audition],
        remark: params[:remark])
      flash[:success] = '安排面试成功'
      redirect_to newest_resumes_company_resumes_path(@company,params[:id])
    else
      flash[:success] = '安排面试失败'
      get_positions_and_resumes_record "-最新简历",DeliveryResumeRecord::STATUS[:newest]
      render 'newest_resumes'
    end
  end

  def deal_join
    positions_and_resumes = DeliveryResumeRecord.find_by_id(params[:id])
    join_time = params[:join_time]
    join_addr = params[:join_addr]
    if positions_and_resumes
      positions_and_resumes.update_attributes(join_time: join_time,
        join_addr: join_addr,
        status: DeliveryResumeRecord::STATUS[:pass],
        join_remark: params[:join_remark])
      flash[:success] = '安排入职成功'
      redirect_to audition_resume_company_resumes_path(@company,params[:id])
    else
      flash[:success] = '安排入职失败'
      get_positions_and_resumes_record "-面试简历",DeliveryResumeRecord::STATUS[:audition]
      render 'audition_resume'
    end
  end

  def choice_position
    status = params[:status].to_i
    postion_id = params[:postion_id]
    start_time = params[:start]
    end_time = params[:end]
    case status
    when DeliveryResumeRecord::STATUS[:newest]
      get_positions_and_resumes postion_id,start_time,end_time,DeliveryResumeRecord::STATUS[:newest]
      render 'newest_resumes'
    when DeliveryResumeRecord::STATUS[:refuse]
      get_positions_and_resumes postion_id,start_time,end_time,DeliveryResumeRecord::STATUS[:refuse]
      render 'refuse_resume'
    when DeliveryResumeRecord::STATUS[:audition]
      get_positions_and_resumes postion_id,start_time,end_time,DeliveryResumeRecord::STATUS[:audition]
      render 'audition_resume'
    when DeliveryResumeRecord::STATUS[:pass]
      get_positions_and_resumes postion_id,start_time,end_time,DeliveryResumeRecord::STATUS[:pass]
      render 'pass_resume'
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

  def show_resume
    @company = Company.find_by_id(params[:company_id])
    @company_id = params[:company_id].nil? ? nil : params[:company_id].to_i
    @client_resume =ClientResume.find_by_id(params[:client_resume_id])
    
    @open_id = @client_resume.open_id
    @cr = ClientResume.find_by_open_id_and_company_id(@open_id, @company_id)
    if @company_id.nil? || @open_id.nil? || @cr.nil? || @cr.html_content_datas.nil?
      @err_msg = "数据错误!"
    else
      @resume_temp = ResumeTemplate.find_by_id(@cr.resume_template_id)
      if @resume_temp.nil? || @resume_temp.html_content.nil?
        @err_msg = "简历模板丢失!"
      else
        @html_content_datas = @cr.html_content_datas
        @html_content = @resume_temp.html_content
        @file_and_image_hash = {}
        @html_content_datas.each do |k,v|
          if k == "headimage"
            @file_and_image_hash[k] = v
          elsif k.include?("file")
            @file_and_image_hash[k] = v
          end
        end
      end
    end
    render 'client_resumes/edit'
  end

  def destroy
    @deliveryresumerecord = DeliveryResumeRecord.find_by_id(params[id])
    if @deliveryresumerecord
      @deliveryresumerecord.destroy
      flash[:success] = '删除成功！'
      redirect_to refuse_resume_company_resumes_path(@company)
    else
      flash[:error] = '删除失败，不存在该简历！'
      redirect_to refuse_resume_company_resumes_path(@company)
    end
  end
  private
  def get_positions_and_resumes position_id,start_time,end_time,status
    @title+="-最新简历"
    @status = status
    @positions = @company.positions.where("status = 2")

    @positions_and_resumes =  ClientResume.
      where(["drr.status= ? and drr.created_at >= ? and drr.created_at <= ? and p.id = ?",status,start_time,end_time,position_id ]).
      joins("inner join delivery_resume_records drr on drr.client_resume_id = client_resumes.id").
      joins("inner join positions p on drr.position_id = p.id ").
      select("drr.id,p.name,
             p.id position_id,
             client_resumes.id client_resume_id,
             client_resumes.html_content_datas,
             client_resumes.clint_name,
             client_resumes.client_phone,
             drr.created_at,
             drr.updated_at,
             drr.status,
             drr.audition_time,
             drr.audition_addr,
             drr.remark,
             drr.join_time,
             drr.join_addr,
             drr.join_remark").paginate(page: params[:page],per_page:PerPage)
   
  end
  def get_title
    @title = "简历"
  end
  def get_company
    @company = Company.find_by_id(params[:company_id].to_i)
  end
end
