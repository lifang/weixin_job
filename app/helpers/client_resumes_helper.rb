#encoding:utf-8
module ClientResumesHelper
  def get_accessory_from hash
    hash.each do |k,v|
      if k.to_s.include?("file")
         return v.values[0]
      end
    end
    ""
  end
end
