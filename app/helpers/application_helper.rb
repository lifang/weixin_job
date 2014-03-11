#encoding:utf-8
module ApplicationHelper

  MW_URL = "http://58.240.210.42" #服务器地址

  WEIXIN_OPEN_URL = "https://api.weixin.qq.com"  #微信api地址
  WEIXIN_DOWNLOAD_URL = "http://file.api.weixin.qq.com"  #微信文件地址
  DOWNLOAD_RESOURCE_ACTION = "/cgi-bin/media/get?access_token=%s&media_id=%s"  #微信下载资源 action
  GET_USER_INFO_ACTION = "/cgi-bin/user/info?access_token=%s&openid=%s&lang=zh_CN" #微信获取用户基本信息action
  ACCESS_TOKEN_ACTION = "/cgi-bin/token?grant_type=client_credential&appid=%s&secret=%s" #微信获取access_token action
  CREATE_MENU_ACTION = "/cgi-bin/menu/create?access_token=%s"


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
    ele = ""
    optional_fileds.each do |ele_type_name, label_and_options|
      label_name = label_and_options["name"]
      options = label_and_options["options"]
      if client_html_content && client_html_content[label_name]
        saved_value = client_html_content[label_name]
      end
      # input
      if ele_type_name.include?("message")
        ele += "<div class='infoItem itemBox'>
                     <div><label>#{label_name}</label><input type='text' name='app_client[#{ele_type_name}]' value= '#{saved_value}' /></div>
                </div>"
        #单选
      elsif ele_type_name.include?("radio")
        radio=""

        options.each do |value|
          radio += "<div><input type='radio' name='app_client[#{ele_type_name}]' value='#{value}'  #{saved_value && saved_value == value ? 'checked=checked' : ''} /><span>#{value}</span></div>"
        end
        ele += "<div class='radioItem itemBox'>
                    <div><span>#{label_name}</span></div>
                      #{radio}
                </div>"

        #多选~~~
      elsif ele_type_name.include?("checkbox")
        checkbox = ""
        options.each do |value|
          checkbox += "<div><input type='checkbox' name='app_client[#{ele_type_name}][]' value='#{value}'  #{saved_value && saved_value.include?(value) ? 'checked=checked' : ''}/><span>#{value}</span></div>"
        end
        ele += " <div class='checkItem itemBox'>
                    <div><span>#{label_name}</span></div>
                        #{checkbox}
                </div>"
        #标签
      elsif ele_type_name.include?("tag")
        checkbox = ""
        options.each do |value|
          checkbox += "<div><input type='checkbox' name='tags[#{ele_type_name}][]' value='#{value}' #{tag_names.include?(value) ? 'checked=checked' : ''}/><span>#{value}</span></div>"
        end
        ele += "<div class='checkItem itemBox'>
                    <div><span>#{label_name}</span></div>
                        #{checkbox}
                </div>"
        #下拉框
      elsif ele_type_name.include?("select")
        select = ""
        options.each do |value|
          select += "<option value='#{value}' #{saved_value == value ? 'selected=selected' : ''}>#{value}</option>"
        end

        ele += "<div class='selectItem itemBox'>
                  <label>#{label_name}</label>
                 <select name=app_client[#{ele_type_name}]>#{select}</select>
        "
      end
    end
    ele
  end

end
