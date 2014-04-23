#encoding: utf-8
class MicroImgtext < ActiveRecord::Base
  belongs_to :micro_message
  attr_protected :authenticate

  Micro_message_resource_path = Rails.root.to_s+ "/public/companies/%d/micro_messages_resource/"
  
  def self.save_and_return_file_path(file, company)
    #图片类别
    @img_resources =%w[jpg png gif jpeg]
    ext_name = File.extname(file.original_filename)[1..-1].downcase
    if @img_resources.include?(ext_name)
      #利用时间整数做名字
      timename = Time.new.to_i
      begin
        company_micro_message_path = Micro_message_resource_path % company.id
        FileUtils.mkdir_p company_micro_message_path unless Dir.exist?(company_micro_message_path)
        new_file_name = "#{timename}.#{ext_name}"
        new_file_path = company_micro_message_path + new_file_name
        File.open(new_file_path, "wb"){|f| f.write file.read}
        min_image(new_file_path,new_file_name,company_micro_message_path)
      rescue Exception => e
        raise e
      else
        return {:status => 0, :file_path => "/companies/#{company.id}/micro_messages_resource/#{new_file_name}"}
      end
    else
      return {:status => -1, :msg => "只允许（gif，png，jpg， jpeg）图片"}
    end
  end

    #资源全路径,文件名 ,dir
  def self.min_image(ful_path,filename,ful_dir)
    target_path=ful_dir+"/"+filename.split(".")[0...-1].join(".")+"_min."+filename.split(".")[-1]
    if !File.exist?(target_path)
      image = MiniMagick::Image.open(ful_path)
      image.resize "360x200"
      image.write  ful_dir+"/"+filename.split(".")[0...-1].join(".")+"_min1."+filename.split(".")[-1]
      image.resize "200x200"
      image.write  ful_dir+"/"+filename.split(".")[0...-1].join(".")+"_min2."+filename.split(".")[-1]
    end
  end

end
