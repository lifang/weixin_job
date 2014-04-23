class Keyword < ActiveRecord::Base
  belongs_to :company
  belongs_to  :micro_message
  attr_protected :authenticate

  TYPE_STR = ["auto", "keyword"]
  TYPE = {:auto => 0, :keyword => 1}  #types: 0 => 自动回复, 1 =>关键词回复

  TYPE_STR.each do |type|
    #取出等于 type的集合
    scope type.to_sym, :conditions => { :types => TYPE[type.to_sym] }
    define_method  "#{type}?" do
      self.types == TYPE[type.to_sym]
    end
  end
end
