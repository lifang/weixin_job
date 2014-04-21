#encoding:utf-8
class CompanyProfilesController < ApplicationController

  before_filter :has_sign?
  before_filter :get_title
  def index
    @company_profiles = @company.company_profiles
  end
  def new
    @company_profiles = @company.company_profiles
  end
  def edit
    @company_profiles = @company.company_profiles
    @company_profile = CompanyProfile.find_by_id(params[:id])
    render 'new'
  end
  def create
    @company_profiles = @company.company_profiles
    img_arr = params[:image]
    text_arr = params[:text]
    html_content = params[:html_content]
    title = params[:title].strip
    @title_1 = title
    file_name = Time.now.to_i.to_s
    update_or_create = params[:update_or_create]
    if update_or_create == "create"
      if CompanyProfile.find_by_title_and_company_id(title,@company.id).blank? &&
          CompanyProfile.find_by_title_and_company_id((get_relative_path_by @company.id.to_s,file_name+".html"),@company.id).blank?
        @company_profile = @company.company_profiles.build do |c|
          c.title = title
          c.html_content = html_content
          c.file_path=get_relative_path_by @company.id.to_s,file_name+".html"
        end
        if @company_profile.save
          save_as_html img_arr,text_arr,file_name
          flash[:success] = '创建成功！'
          redirect_to company_company_profiles_path(@company)
        else
          flash[:error] = "创建失败,#{@company_profile.errors.messages.values.flatten.join("\\n")}"
          redirect_to new_company_company_profile_path(@company)
        end
      else
        flash[:error] = "已经存在该标题或文件名"
        redirect_to new_company_company_profile_path(@company)
      end
    else
      update_tuwen img_arr,text_arr,html_content,title,file_name
    end
  end

  def update_tuwen img_arr,text_arr,html_content,title,file_name
    id = params[:company_profile_id]
    file_path =get_relative_path_by @company.id.to_s,file_name+".html"
    @company_profile = CompanyProfile.find_by_id(id)
    if @company_profile && @company_profile.update_attributes(html_content:html_content,title:title,file_path:file_path)
      save_as_html img_arr,text_arr,file_name
      flash[:success] = '更新成功！'
      redirect_to company_company_profiles_path(@company)
    else
      flash[:error] = "更新失败,不存在简介"
      redirect_to new_company_company_profile_path(@company)
    end
  end

  def upload_img
    @image = params[:image]
    @img_resources = %w[jpg png gif jpeg]
    postfix_name = @image.original_filename.split('.')[-1]
    if @img_resources.include?(postfix_name.downcase) && @image.size<1*1024*1024
      @index = params[:index]
      time_str = Time.now.usec
      old_img_url = params[:old_img][4...-1]
      @root_path = Rails.root.to_s + "/public/companies/"+@company.id.to_s+"/company_profiles"
      unless old_img_url.blank?
        file_name = old_img_url.split("/")[-1]
        file_path = @root_path +"/"+file_name
        FileUtils.rm file_path if File.exists?(file_path)
      end
      FileUtils.mkdir_p @root_path unless Dir.exist?(@root_path)
      @full_path = @root_path +"/#{time_str}"+ @image.original_filename
      @img_path = "/companies/"+@company.id.to_s+"/company_profiles/#{time_str}"+ @image.original_filename
      file1=File.new(@full_path,'wb')
      FileUtils.cp @image.path,file1
      @msg = "success"
    else
      @msg = "请上传图片(jpg/png/gif)或图片大小超限"
    end
  end
  
  def show_tuwen_page
    @company_profile = CompanyProfile.find_by_id(params[:id])
    @message =""
    if @company_profile
    else
      @message ="不存在该图文！"
    end

  end

  def destroy
    @company_profile = CompanyProfile.find_by_id(params[:id])
    file_path = @company_profile.file_path
    if @company_profile && @company_profile.destroy
      destroy_file file_path
      flash[:success] = '删除成功！'
      redirect_to company_company_profiles_path(@company)
    else
      flash[:success] = '删除失败！公司简介不存在！'
      render 'index'
    end
  end

  def get_title
    @title = "微网页"
  end
  private
  def destroy_file file_path
    file_absolute_path = Rails.root.to_s + "/public#{file_path}"
    FileUtils.rm file_absolute_path if File.exists?(file_absolute_path)
  end

  def save_as_html img_arr,text_arr,filename
    content = html_content img_arr,text_arr
    file_path = Rails.root.to_s + "/public/companies/#{@company.id.to_s}/#{filename}.html"
    dir_path = get_company_dir_path @company.id.to_s
    FileUtils.mkdir_p(dir_path) unless Dir.exists?(dir_path)
    FileUtils.rm(file_path) if File.exists?(file_path)
    File.open(file_path, "wb") do |f|
      f.write(content.html_safe)
    end
  end
  def html_content img_arr,text_arr
    tuwen = ""
    img_arr.each_with_index do |img , index|
      imge = (img=="#" ? "" : "<img src='#{img}' />")
      txt = (text_arr[index].nil? ? "":"<p>#{  (text_arr[index].html_safe)}</p>")
      tuwen += "
			#{imge}
			#{txt}
      "
    end
    html = "
      <!DOCTYPE html PUBLIC '-//W3C//DTD XHTML 1.0 Transitional//EN' 'http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd'>
<html xmlns='http://www.w3.org/1999/xhtml'>
<head>
<meta http-equiv='Content-Type' content='text/html; charset=utf-8' />
<meta name='viewport' content='width=device-width, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=no'>
<script src='/assets/mobilephone/jquery-1.8.3.js' type='text/javascript'></script>
<script src='/assets/mobilephone/main2.js' type='text/javascript'></script>
<link href='/assets/style2.css' rel='stylesheet' type='text/css' />
<title>#{@company.name}-#{@title_1}</title>
<script>
	$(function(){
	})
</script>
</head>
<body>
<article>
<section class='title'>#{@company.name}</section>
    <section class='area'>
    	<div class='about'>
      #{tuwen}
	  </div>
    </section>
</article>
</body>
</html>
    "
  end

  

end
