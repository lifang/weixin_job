#encoding: utf-8
class ResumeTemplate < ActiveRecord::Base
  serialize :html_content
  belongs_to :company
  has_many :client_resumes

  def self.get_html resume
    html_head = "<!DOCTYPE html PUBLIC '-//W3C//DTD XHTML 1.0 Transitional//EN' 'http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd'>
    <html xmlns='http://www.w3.org/1999/xhtml'>
  <head>
    <meta http-equiv='Content-Type' content='text/html; charset=utf-8'/>
    <script src='/companies/jquery-1.8.3.js' type='text/javascript'></script>
    <script src='/companies/main2.js' type='text/javascript'></script>
    <link href='/companies/style2.css' rel='stylesheet' type='text/css' />
    <title>微招聘-客户简历</title>
  </head>
  <body>
    <div class='form_list'>
    <form id='create_client_resume_form' action='/companies/#{resume.company_id}/client_resumes' accept-charset='UTF-8' method='post' enctype='multipart/form-data'>
    <input name='utf8' type='hidden' value='✓'/>
    <input class='authenticity_token' name='authenticity_token' type='hidden' value=''/>"

    resume.html_content.each do |k, v|
      if k.to_s.include?("message")
        html_head << "<div class='infoItem itemBox'><div><label>#{v[:name]}</label><input type='text' name='[form_p][#{k.to_s}][#{v[:name]}]'/></div></div>"
      elsif k.to_s.include?("radio")
        html_head << "<div class='radioItem itemBox'><div><span>#{v[:name]}</span></div>"
        html_head << "<div><input type='radio' name='[form_p][#{k.to_s}][#{v[:name]}]' value='#{v[:options][0]}' checked/><span>#{v[:options][0]}</span></div>"
        v[:options][1..v[:options].length-1].each do |o|
          html_head << "<div><input type='radio' name='[form_p][#{k.to_s}][#{v[:name]}]' value='#{o}'/><span>#{o}</span></div>"
        end if v[:options][1..v[:options].length-1]
        html_head << "</div>"
      elsif k.to_s.include?("checkbox")
        html_head << "<div class='checkItem itemBox'><div><span>#{v[:name]}</span></div>"
        v[:options].each do |o|
          html_head << "<div><input type='checkbox' name='[form_p][#{k.to_s}][#{v[:name]}][]' value='#{o}'/><span>#{o}</span></div>"
        end
        html_head << "</div>"
      elsif k.to_s.include?("select")
        html_head << "<div class='selectItem itemBox'><label>#{v[:name]}</label>"
        html_head << "<select name='[form_p][#{k.to_s}][#{v[:name]}]'>"
        v[:options].each do |o|
          html_head << "<option value='#{o}'>#{o}</option>"
        end
        html_head << "</select></div>"
      elsif k.to_s.include?("text")
        html_head << "<div class='txtItem itemBox'>"
        html_head << "<p>#{v[:text]}</p>"
        html_head << "<input type='hidden' name='[form_p][#{k.to_s}][#{:text}]' value='#{v[:text]}'/>"
        html_head << "</div>"
      elsif k.to_s.include?("headimage")
        html_head << "<div class='imgItem itemBox'><label>#{v[:name]}</label>"
        html_head << "<input type='file' name='[form_p][#{k.to_s}][#{v[:name]}]'/>"
        html_head << "</div>"
      elsif k.to_s.include?("file")
        html_head << "<div class='imgItem itemBox'><label>#{v[:name]}</label>"
        html_head << "<input type='file' name='[form_p][#{k.to_s}][#{v[:name]}]'/>"
        html_head << "</div>"
      end
    end if resume.html_content

    html_head << "<div class='form_btn'><button type='button' onclick='client_resume_valid(this)'>提交</button></div></form>"
    html_head << "</div></body></html>"
    root_path = Rails.root.to_s + "/public/companies/#{resume.company_id}/resumes/"
    FileUtils.mkdir_p(root_path) unless Dir.exists?(root_path)
    file_name = "resume.html"
    File.delete root_path + file_name if File.exists?( root_path + file_name)
    File.open(root_path + file_name, "wb") do |f|
      f.write(html_head.html_safe)
    end
    url = root_path + file_name
    resume.update_attribute("html_url", url)
  end

  
  #  def save_html comp_id, content
  #    root_path = Rails.root.to_s + "/public/companies/#{comp_id}/resumes/"
  #    FileUtils.mkdir_p(root_path) unless Dir.exists?(root_path)
  #    file_name = "resume.html"
  #    File.delete root_path + file_name if File.exists?( root_path + file_name)
  #     File.open(root_path + file_name, "wb") do |f|
  #      f.write(content.html_safe)
  #    end
  #    return root_path + file_name
  #  end

end
