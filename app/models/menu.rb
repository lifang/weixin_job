#encoding: utf-8
class Menu < ActiveRecord::Base
  belongs_to :company
  type_names_arr = [:comapny_profile, :positions, :resume]
  TYPES = {:comapny_profile => 0, :positions => 1, :resume => 2} #菜单类型：公司简介，职位， 简历模板
  TYPE_NAMES = {0 => "company_profile", 1 => "positions", 2 => "resume"} #菜单类型：公司简介，职位， 简历模板
  scope :one_level, ->{where("parent_id = 0")}
  
  type_names_arr.each do |type|
    scope type, :conditions => { :types => TYPES[type] }
    define_method  "#{type.to_s}?" do
      self.types == TYPE_NAMES[type]
    end
  end

  def children
    Menu.where({:company_id => company_id, :parent_id => id})
  end

end