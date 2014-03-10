#encoding: utf-8
class ResumesController < ApplicationController   #简历模板
  before_filter :get_title
  before_filter :has_sign?
  def index
    @company = Company.find_by_id(params[:company_id].to_i)
    resume_temp = ResumeTemplate.find_by_company_id(@company.id)
    if resume_temp
      @resume_temp = resume_temp
    else
      @resume_temp = @company.resume_templates.create
    end
  end

  def add_form_item
    @name = params[:name] #message_div
    @title_name = params[:title_name] #message_24
    if @name != "success_div"
      @item_tile = params[:item_title]
      if @name == "radio_div" || @name=="check_box_div" || @name=="select_div"
        @options = params[:options]
      end
    else
      @alert = params[:al]
      @phone = params[:phone]
      @address = params[:address]
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

  def get_title
    @title = "简历模板"
  end
end
