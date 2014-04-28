#encoding:utf-8
require 'iconv'
module ApplicationHelper
  require "json"
  require 'net/http'
  require "uri"
  require 'openssl'
  include Weixin

  def is_hover?(*controller_name)
    controller_name.each do |name|
      if request.url.include?(name)
        return "hover"
      else
        return ""
      end
    end
  end

  
  def get_absolute_path_by(company_id,file_name)
    Rails.root.to_s+"/public/companies/#{company_id}/#{file_name}"
  end
  def get_relative_path_by(company_name,file_name)
    "/companies/#{company_name}/#{file_name}"
  end
  def get_company_dir_path(company_name)
    Rails.root.to_s+"/public/companies/#{company_name}"
  end

  def get_element_html(client_html_content, optional_fileds, tag_names)
    ele = "<ul>"
    client_html_content = change_string_to_hash(client_html_content) if client_html_content
    optional_fileds.each do |ele_type_name, label_and_options|
      label_name = label_and_options["name"]
      options = label_and_options["options"]
      if client_html_content && client_html_content[label_name]
        saved_value = client_html_content[label_name]
      end
      label_name = CGI.escapeHTML(label_name) if label_name
      # input
      if ele_type_name.include?("message")
        ele += "<li class='infoItem itemBox'>
                     <label>#{label_name}</label>
<input type='text' name='app_client[#{ele_type_name}]' value= '#{saved_value}' />
                </li>"
        #单选
      elsif ele_type_name.include?("radio")
        radio=""

        options.each do |value|
          value = CGI.escapeHTML(value)
          radio += "<p><input type='radio' name='app_client[#{ele_type_name}]' value='#{value}'  #{saved_value && saved_value == value ? 'checked=checked' : ''} />#{value}</p>"
        end
        ele += "<li class='radioItem itemBox'>
                   <label>#{label_name}</label>
                      #{radio}
                </li>"

        #多选~~~
      elsif ele_type_name.include?("checkbox")
        checkbox = ""
        options.each do |value|
          value = CGI.escapeHTML(value)
          checkbox += "<p><input type='checkbox' name='app_client[#{ele_type_name}][]' value='#{value}'  #{saved_value && saved_value.include?(value) ? 'checked=checked' : ''}/>#{value}<p>"
        end
        ele += " <li class='checkItem itemBox'>
                    <label>#{label_name}</label>
                        #{checkbox}
                </li>"
        #标签
      elsif ele_type_name.include?("tag")
        checkbox = ""
        options.each do |value|
          value = CGI.escapeHTML(value)
          checkbox += "<p><input type='checkbox' name='tags[#{ele_type_name}][]' value='#{value}' #{tag_names.include?(value) ? 'checked=checked' : ''}/>#{value}</p>"
        end
        ele += "<li class='checkItem itemBox'>
                    <label>#{label_name}</label>
                        #{checkbox}
                </li>"
        #下拉框
      elsif ele_type_name.include?("select")
        select = ""
        options.each do |value|
          value = CGI.escapeHTML(value)
          select += "<option value='#{value}' #{saved_value == value ? 'selected=selected' : ''}>#{value}</option>"
        end

        ele += "<li class='selectItem itemBox'>
                  <label>#{label_name}</label>
                 <select name=app_client[#{ele_type_name}]>#{select}</select>
                </li>"
      elsif ele_type_name.include?("text")
        text = label_and_options["text"]
        text = CGI.escapeHTML(text)
        ele +="<li class='txtItem itemBox'>
                 <h1>#{text}</h1>
               </li>"
      end
    end if optional_fileds
    ele
  end

  #{'年龄'=>'24','性别'=>'女','喜欢的季节'=>'春、夏','喜欢的城市'=>'苏州'}
  def change_string_to_hash client_html_content
    tmp_client_html_content = client_html_content.delete("{").delete("}")
    tmp_client_html_arr = tmp_client_html_content.split(",")
    client_html_hash = {}
    tmp_client_html_arr.each do |ele|
      ele_k, ele_v = ele.split("=>")
      ele_k = ele_k.delete("'")
      ele_v = ele_v.delete("'")
      client_html_hash[ele_k] = ele_v.include?("、") ? ele_v.split("、") : ele_v
    end
    client_html_hash
  end

  def encoding_character(str)
    arr={"<"=>"&lt;",">"=>"&gt;"}
    str.gsub(/<|>/){|s| arr[s]}
  end

  def set_charset hash
    ic = Iconv.new("GBK", "utf-8")    #GBK转码utf-8
    hash2 = {}
    hash.each do |k, v|   #message_1"=>{"\xE5\xA7\x93\xE5\x90\x8D"=>"wadawd"}
      hash1 = {}
      v.each do |k1, v1|  #{"\xE5\xA7\x93\xE5\x90\x8D"=>"wadawd"}
        k1 = ic.iconv(k1)
        hash1[k1] = v1    #{"姓名" => "wadawd"}
      end
      hash2[k] = hash1
    end
    return hash2
  end

  def send_noti_to_ios company_id   #新用户填写简历后推送到ios终端上
    client = Client.find_by_company_id_and_types(company_id, Client::TYPES[:ADMIN])
    token = client.token if client
    if token
      content = "有新用户投递简历!"
      badge = Client.where(["company_id=? and types=? and has_new_message=?", company_id, Client::TYPES[:CONCERNED],
          Client::HAS_NEW_MESSAGE[:YES]]).length
      badge = badge + 1
      APNS.host = 'gateway.sandbox.push.apple.com'
      APNS.pem  = File.join(Rails.root, 'config', 'CMR_Development.pem')
      APNS.port = 2195
      APNS.send_notification(token,:alert => content, :badge => badge, :sound => client.id)
    end
  end

  #辅助，根据总数自定义每页数目
  def set_perpage(total)
    if total < 100
      perpage = 50
    elsif total >= 100 && total <= 1000
      perpage = 200
    elsif total > 1000 && total <= 3000
      perpage = 300
    elsif total > 3000 && total <= 10000
      perpage = 1000
    else
      perpage = 1500
    end
    perpage
  end
  
  #辅助方法，返回分页数
  def pagecount(total)
    perpage = set_perpage(total)
    if total % perpage == 0
      init_page = total/perpage
    else
      init_page = total/perpage + 1
    end
    [init_page,perpage]
  end

  #
  def is_hover_top? controller_name
    arr4 = ["company_profiles"]
    arr3 = ["companies","position_types","address_settings","menus","app_managements", "micro_messages", "weixin_replies"]
    arr2 = ["positions"]
    arr1 = ["resumes","exports"]
    if arr1.include?(controller_name)
      return 1
    elsif arr2.include?(controller_name)
      return 2
    elsif arr3.include?(controller_name)
      return 3
    elsif arr4.include?(controller_name)
      return 4
    end
    0
  end

  #搜索的时候，处理like参数
  def search_content(content)
    content.present? ? content.gsub(/[%_]/){|x| '\\' + x} : ""
  end
end
