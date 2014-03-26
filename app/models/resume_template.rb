#encoding: utf-8
class ResumeTemplate < ActiveRecord::Base
  serialize :html_content
  belongs_to :company
  has_many :client_resumes

  def self.get_html resume

    company = Company.find_by_id(resume.company_id)
    
    html_head = "<!DOCTYPE html PUBLIC '-//W3C//DTD XHTML 1.0 Transitional//EN' 'http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd'>
    <html xmlns='http://www.w3.org/1999/xhtml'>
  <head>
    <meta http-equiv='Content-Type' content='text/html; charset=utf-8'/>
    <meta name='viewport' content='width=device-width, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=no'/>
    <script src='/assets/mobilephone/jquery-1.8.3.js' type='text/javascript'></script>
    <script src='/assets/mobilephone/main2.js' type='text/javascript'></script>
    <link href='/assets/style2.css' rel='stylesheet' type='text/css' />
    <title>#{company.name}-我的简历</title>
  </head>
  <body>
<article>
    <section class='title'>我的简历</section>
    <form id='create_client_resume_form' action='/client_resumes' accept-charset='UTF-8' method='post' enctype='multipart/form-data'>
       <section class='area'>
    	    <div class='input_list'>
    <input name='utf8' type='hidden' value='✓'/>
    <input class='authenticity_token' name='authenticity_token' type='hidden' value=''/>
    <input type='hidden' name='resume_id' value='#{resume.id}'/>
    <input type='hidden' name='company_id' value='#{resume.company_id}'/>
   <ul>"
    resume.html_content.each do |k, v|
      if k.to_s.include?("message")
        html_head << "<li class='infoItem itemBox'><label>#{v[:name]}</label><input type='text' name='[form_p][#{k.to_s}][#{v[:name]}]'/></li>"
      elsif k.to_s.include?("radio")
        html_head << "<li class='radioItem itemBox'><label>#{v[:name]}</label>"
        html_head << "<p><input type='radio' name='[form_p][#{k.to_s}][#{v[:name]}]' value='#{v[:options][0]}' checked/>#{v[:options][0]}</p>"
        v[:options][1..v[:options].length-1].each do |o|
          html_head << "<p><input type='radio' name='[form_p][#{k.to_s}][#{v[:name]}]' value='#{o}'/>#{o}</p>"
        end if v[:options][1..v[:options].length-1]
        html_head << "</li>"
      elsif k.to_s.include?("checkbox")
        html_head << "<li class='checkItem itemBox'><label>#{v[:name]}</label>"
        v[:options].each do |o|
          html_head << "<p><input type='checkbox' name='[form_p][#{k.to_s}][#{v[:name]}][]' value='#{o}'/>#{o}</p>"
        end
        html_head << "</li>"
      elsif k.to_s.include?("select")
        html_head << "<li class='selectItem itemBox'><label>#{v[:name]}</label>"
        html_head << "<select name='[form_p][#{k.to_s}][#{v[:name]}]'>"
        v[:options].each do |o|
          html_head << "<option value='#{o}'>#{o}</option>"
        end
        html_head << "</select></li>"
      elsif k.to_s.include?("text")
        str = ResumeTemplate.encoding_character(v[:text])
        html_head << "<li class='txtItem itemBox'>"
        html_head << "<h1>#{str}</h1>"
        html_head << "<input type='hidden' name='[form_p][#{k.to_s}][#{:text}]' value='#{v[:text]}'/>"
        html_head << "</li>"
      elsif k.to_s.include?("headimage")
        html_head << "<li class='imgItem itemBox'><label>#{v[:name]}</label>"
        html_head << "<input type='file' name='[form_p][#{k.to_s}][#{v[:name]}]'/>"
        html_head << "</li>"
      elsif k.to_s.include?("file")
        html_head << "<li class='imgItem itemBox'><label>#{v[:name]}</label>"
        html_head << "<input type='file' name='[form_p][#{k.to_s}][#{v[:name]}]'/>"
        html_head << "</li>"
      end
    end if resume.html_content

    html_head << "</ul></section><section class='btn'><button type='button' onclick='client_resume_valid(this)'>确定</button></section></form>"
    html_head << "</article></body></html>"
    root_path = "#{Rails.root.to_s}/public/"
    resume_path =  "/companies/#{resume.company_id}/resumes/"
    FileUtils.mkdir_p(root_path + resume_path) unless Dir.exists?(root_path + resume_path)
    file_name = "resume.html"
    File.delete root_path + resume_path + file_name if File.exists?( root_path + resume_path + file_name)
    File.open(root_path + resume_path + file_name, "wb") do |f|
      f.write(html_head.html_safe)
    end
    url = resume_path + file_name
    resume.update_attribute("html_url", url)
  end

  
  def self.encoding_character(str)
    arr={"<"=>"&lt;",">"=>"&gt;"}
    str.gsub(/<|>/){|s| arr[s]}
  end

end
