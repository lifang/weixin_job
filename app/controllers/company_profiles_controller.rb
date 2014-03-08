#encoding:utf-8
class CompanyProfilesController < ApplicationController
  before_filter :get_company
  before_filter :has_sign?
  before_filter :get_title
  def index
    @company_profiles = @company.company_profiles
  end
  def new
    @company_profiles = @company.company_profiles
  end
  def create
    @company_profiles = @company.company_profiles
    img_arr = params[:image]
    text_arr = params[:text]
    html_content = params[:html_content]
    title = params[:title]
    file_name = params[:file_name]
    if CompanyProfile.find_by_title(title).blank?
      @company_profile = @company.company_profiles.build do |c|
        c.title = title
        c.html_content = html_content
        c.file_path=get_relative_path_by @company.name,file_name+".html"
      end
      if @company_profile.save
        save_as_html img_arr,text_arr,file_name
        flash[:success] = '创建成功！'
        redirect_to company_company_profiles_path(@company)
      else
        flash[:error] = "创建失败"
        render 'new'
      end
    else
      flash[:error] = "#{@company_profile.errors.messages.values.flatten.join("\\n")}"
      render 'new'
    end

  end
  def upload_img
    @image = params[:image]
    @index = params[:index]
    old_img_url = params[:old_img][4...-1]
    @root_path = Rails.root.to_s + "/public/companies/"+@company.name+"/company_profiles"
    unless old_img_url.blank?
      file_name = old_img_url.split("/")[-1]
      file_path = @root_path +"/"+file_name
      FileUtils.rm file_path
    end
    FileUtils.mkdir_p @root_path unless Dir.exist?(@root_path)
    @full_path = @root_path +"/"+ @image.original_filename
    @img_path = "/companies/"+@company.name+"/company_profiles/"+ @image.original_filename
    file1=File.new(@full_path,'wb')
    FileUtils.cp @image.path,file1
  end

  def get_title
    @title = "公司简介"
  end
  private
  def save_as_html img_arr,text_arr,filename
    content = html_content img_arr,text_arr
    file_path = Rails.root.to_s + "/public/companies/#{@company.name}/#{filename}.html"
    dir_path = get_company_dir_path @company.name
    FileUtils.mkdir_p(dir_path) unless Dir.exists?(dir_path)
    File.open(file_path, "wb") do |f|
      f.write(content.html_safe)
    end
  end
  def html_content img_arr,text_arr
    p 22222222222222222,img_arr,text_arr
    tuwen = ""
    img_arr.each_with_index do |img , index|
      imge = (img=="#" ? "" : "<img src='#{img}' />")
      txt = (text_arr[index].nil? ? "":"<p>#{text_arr[index]}</p>")
      tuwen += "
      <div class='tuwenBox'>
			<div class='tuwenImg'>
				#{imge}
			</div>
			#{txt}
		</div>
      "
    end
    html = "
      <!DOCTYPE html PUBLIC '-//W3C//DTD XHTML 1.0 Transitional//EN' 'http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd'>
<html xmlns='http://www.w3.org/1999/xhtml'>
<head>
<meta http-equiv='Content-Type' content='text/html; charset=utf-8' />
<script src='js/jquery-1.8.3.js' type='text/javascript'></script>
<script src='js/main2.js' type='text/javascript'></script>
<link href='style/style2.css' rel='stylesheet' type='text/css' />
<title>微招聘-公司简介</title>
<script>
	$(function(){
	})
</script>
</head>
<body>
	<div class='jobInfo'>
		#{tuwen}
	</div>
</body>
</html>
    "
  end
end
