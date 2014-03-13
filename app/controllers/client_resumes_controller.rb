#encoding: utf-8
require 'iconv'
class ClientResumesController < ApplicationController
  layout :false
  def create
    ClientResume.transaction do
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
      status = 1
      @err_msg = ""
      if secret_id.nil?
        status = 0
        @err_msg = "数据错误!"
      else
        cr = ClientResume.find_by_open_id_and_company_id(secret_id, company_id)
        if cr
          hash.each do |k, v|
            if k.to_s.include?("headimage")
              v.each do |name, img|
                status, img_url, @err_msg = ClientResume.upload_headimg(img, company_id, secret_id)
                if status == 1
                  hash[k][name] = img_url
                else
                  hash[k][name] = ""
                  break
                end
              end
              if status == 0
                break
              end
            elsif k.to_s.include?("file")
              v.each do |name, file|
                status, file_url, @err_msg = ClientResume.upload_file(file, company_id, secret_id)
                if status == 1
                  hash[k][name] = file_url
                else
                  hash[k][name] = ""
                  break
                end
              end
              if status == 0
                break
              end            
            end
          end

          if status == 1
            if cr.update_attribute("html_content_datas", hash)
              @err_msg = "简历填写成功!"
            else
              @err_msg = "简历填写失败!"
            end
          end

        else

          hash.each do |k, v|
            if k.to_s.include?("headimage")
              v.each do |name, img|
                status, img_url, @err_msg = ClientResume.upload_headimg(img, company_id, secret_id)
                if status == 1
                  hash[k][name] = img_url
                else
                  hash[k][name] = ""
                  break
                end
              end
              if status == 0
                break
              end
            elsif k.to_s.include?("file")
              v.each do |name, file|
                status, file_url, @err_msg = ClientResume.upload_file(file, company_id, secret_id)
                if status == 1
                  hash[k][name] = file_url
                else
                  hash[k][name] = ""
                  break
                end
              end
              if status == 0
                break
              end          
            end
          end
        
          if status == 1
            cr = ClientResume.new(:html_content_datas => hash, :resume_template_id => params[:resume_id], :has_completed => true,
              :open_id => secret_id, :company_id => company_id)
            if cr.save
              @err_msg = "简历填写成功!"
            else
              status = 0
              @err_msg = "简历填写失败!"
            end
          
          end
        end
      end
      render "completed"
    end
  end

  def edit
    @company_id = params[:company_id].nil? ? nil : params[:company_id].to_i
    @open_id = params[:secret_key]
    @cr = ClientResume.find_by_open_id_and_company_id(@open_id, @company_id)
    if @company_id.nil? || @open_id.nil? || @cr.nil? || @cr.html_content_datas.nil?
      @err_msg = "数据错误!"
    else
      @resume_temp = ResumeTemplate.find_by_id(@cr.resume_template_id)
      if @resume_temp.nil? || @resume_temp.html_content.nil?
        @err_msg = "简历模板丢失!"
      else
        @html_content_datas = @cr.html_content_datas
        @html_content = @resume_temp.html_content
        @file_and_image_hash = {}
        @html_content_datas.each do |k,v|
          if k == "headimage"
            @file_and_image_hash[k] = v
          elsif k.include?("file")
            @file_and_image_hash[k] = v
          end
        end
      end
    end
  end

  def update
    ClientResume.transaction do      
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
      cr = ClientResume.find_by_id(params[:id])
      company_id = params[:company_id]
      secret_id = params[:open_id]
      status = 1
      @err_msg = ""
      hash.each do |k, v|
        if k.to_s.include?("headimage")
          v.each do |name, img|
            status, img_url, @err_msg = ClientResume.upload_headimg(img, company_id, secret_id)
            if status == 1
              hash[k][name] = img_url
            else
              hash[k][name] = ""
              break
            end
          end
          if status == 0
            break
          end
        elsif k.to_s.include?("file")
          v.each do |name, file|
            status, file_url, @err_msg = ClientResume.upload_file(file, company_id, secret_id)
            if status == 1
              hash[k][name] = file_url
            else
              hash[k][name] = ""
              break
            end
          end
          if status == 0
            break
          end
        end
      end
      old_hash = cr.html_content_datas
      oh2 = {}
      old_hash.each do |k, v|
        if k == "headimage" || k.include?("file")
          oh2[k] = v
        end
      end
      oh2.each do |k,v|
        if hash[k].nil?
          hash.merge!({k => v})
        end
      end

      if status == 1
        if cr.update_attribute("html_content_datas", hash)
          @err_msg = "简历更新成功!"
        else
          @err_msg = "简历更新失败!"
        end
      end

      render "completed"
    end
  end

  def completed
    
  end

end

