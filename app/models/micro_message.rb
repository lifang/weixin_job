#encoding:utf-8
class MicroMessage < ActiveRecord::Base
  has_many :micro_imgtexts, :dependent => :destroy
  has_one :keyword
  belongs_to :company
  attr_protected :authenticate

  TYPE_STR = ["text", "image_text"]
  TYPE = {:text => false, :image_text => true}  #mtype:false代表文字，true代表图文

  SOLID_LINK = {:ggl => 0, :app => 1}  #消息回复 0 是刮刮乐  1是 app
  
  TYPE_STR.each do |ts|
    scope ts.to_sym, :conditions => { :mtype => TYPE[ts.to_sym] }
     define_method  "#{ts}?" do
      self.mtype == TYPE[ts.to_sym]
    end
  end
end
