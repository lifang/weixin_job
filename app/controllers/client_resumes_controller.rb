#encoding: utf-8
require 'iconv'
class ClientResumesController < ApplicationController

  def create
    ClientResume.transaction
    ic = Iconv.new("GBK", "utf-8")    #GBK转码utf-8
    tags = params[:form_p]
    hash = {}
    tags.each do |k, v|   #message_1"=>{"\xE5\xA7\x93\xE5\x90\x8D"=>"wadawd"}
      hash1 = {}
      v.each do |k1, v1|  #{"\xE5\xA7\x93\xE5\x90\x8D"=>"wadawd"}
        k1 = ic.iconv(k1)
        hash1[k1] = v1    #{"姓名" => "wadawd"}
      end
      hash[k] = hash1
    end
    secret_id = params[:secret_id]
    company_id = params[:company_id].to_i
    if secret_id.nil?
      @err_msg = "数据错误!"
    else
      cr = ClientResume.find_by_open_id(secret_id)      
      if cr
       
      else
        hash.each do |k, v|
          if k.to_s.include?("headimage")
            v.each do |name, img|
              img_url = ClientResume.upload_headimg(img, company_id, secret_id, [148,154,50,800])
              hash[k][name] = img_url
            end
          elsif k.to_s.include?("file")
            v.each do |name, file|
              file_url = ClientResume.upload_file(file, company_id, secret_id)
              hash[k][name] = file_url
            end
          end
        end
        cr = ClientResume.new(:html_content_datas => hash, :resume_template_id => params[:resume_id], :has_completed => true,
          :open_id => secret_id)
        if cr.save
          @msg = "简历填写成功!"
        end
        @err_msg = "简历填写失败!"
      end
      render :json => {:a => hash}
    end
  end


end

