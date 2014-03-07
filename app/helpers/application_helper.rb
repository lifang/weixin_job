#encoding:utf-8
module ApplicationHelper
  MW_URL = "http://demo.sunworldmedia.com/" #服务器地址

  def is_hover?(*controller_name)
    controller_name.each do |name|
      if request.url.include?(name)
        return "hover"
      else
        reruen ""
      end
    end
  end
end
