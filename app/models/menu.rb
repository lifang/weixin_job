#encoding: utf-8
class Menu < ActiveRecord::Base
  belongs_to :company
  type_names_arr = [:comapny_profile, :positions, :resume]
  TYPES = {:comapny_profile => 0, :positions => 1, :resume => 2, :no_type => 3} #菜单类型：公司简介，职位， 简历模板, 没有类别
  TYPE_NAMES = {0 => "company_profile", 1 => "positions", 2 => "resume", 3 => "no_type"} #菜单类型：公司简介，职位， 简历模板
  TEMP_TYPES = {:my_jobs=>-1,:my_recommend=>-2,:search_job =>-3,:newest =>-4}#我的求职，我的推荐
  scope :one_level, ->{where("parent_id = 0")}
  NO_TEMP = 0   #没有关联任何简介、职位、模板时temp_id为0
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