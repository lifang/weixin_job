#encoding: utf-8
class ClientResume < ActiveRecord::Base
  require 'mini_magick'
  serialize :html_content_datas
  belongs_to :resume_template
  has_many :delivery_resume_records
  img_size  = [148,154,50,800]


  def self.upload_headimg img_url, company_id, open_id    #上传头像
    root_path = "#{Rails.root}/public/"   #头像路径 headimages/company_id/open_id/*
    dirs = ["/companies", "/#{company_id}", "/excel", "/headimages"]
    status = 1
    msg = ""
    begin
      dirs.each_with_index {|d, index| Dir.mkdir(root_path + dirs[0..index].join) unless File.directory?(root_path + dirs[0..index].join)}
      img = img_url.original_filename
      img_name = "#{dirs.join}/#{open_id}."+ img.split(".").reverse[0]
      File.open(root_path+ img_name, "wb") { |i| i.write(img_url.read) }    #存入原图     
      size = File.size?(root_path+ img_name)
      if size > 1048576
        status = 0
        msg = "头像上传失败,图片最大不能超过1MB"
      end
      if status == 0
        File.delete(root_path+ img_name)
      end
    rescue
      status = 0
      msg = "上传失败!"
    end
    return [status, img_name, msg]
  end

  def self.upload_file  file_url, company_id, open_id   #上传文件
    status = 1
    msg = ""
    root_path = "#{Rails.root}/public/"   #头像路径 files/company_id/open_id/*
    dirs = ["/companies", "/#{company_id}", "/excel", "/files", "/#{open_id}"]
    begin
      dirs.each_with_index {|d, index| Dir.mkdir(root_path + dirs[0..index].join) unless File.directory?(root_path + dirs[0..index].join)}
      file = file_url.original_filename
      file_name = "#{dirs.join}/#{file.split(".").reverse[1]}."+ file.split(".").reverse[0]
      File.open(root_path+ file_name, "wb") { |i| i.write(file_url.read) }    #存入文件
      size = File.size?(root_path+ file_name)
      if size > 2097152
        status = 0
        msg = "附件上传失败,文件最大不能超过2MB"
        File.delete(root_path+ file_name)
      end
    rescue
      status = 0
      msg = "附件上传失败!"
    end
    return [status, file_name, msg]
  end

end
