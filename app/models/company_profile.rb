#encoding: utf-8
class CompanyProfile < ActiveRecord::Base
  belongs_to :company
  validate :file_path, :uniquess=>true,:message => "文件名存在"
end
