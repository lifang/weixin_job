#encoding: utf-8
require 'iconv'
class ClientResumesController < ApplicationController
  def create
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
    if secret_id.nil?
      msg = "数据错误!"
    else
      cr = ClientResume.find_by_open_id(secret_id)
      if cr
        
      else

      end
    end
    
  end
end
