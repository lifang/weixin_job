#encoding: utf-8
class Menu < ActiveRecord::Base
  belongs_to :company
  
  type_names_arr = [:company_profile, :positions, :my_resume, :my_recommend, :my_jobs, :outside_link, :all_pos, :newest_pos, :nothing]
  #菜单响应类型
  #公司简介（资讯）， 职位，我的简历，我的推荐，我的求职，外部链接，全部职位，最新职位, 无任何类型
  TYPES = {:company_profile => 0, :positions => 1, :my_resume => 2, :my_recommend => 3, :my_jobs => 4, :outside_link => 5, :all_pos =>6, :newest_pos => 7, :nothing => 8}
  
  TYPE_NAMES = {0 => "company_profile", 1 => "positions", 2 => "my_resume", 3 => "my_recommend", 4 => "my_jobs", 5 => "outside_link", 6 => "all_pos", 7 => "newest_pos", 8 => "nothing" }
  TEMP_TYPES = {:my_jobs=>-1,:my_recommend=>-2,:search_job =>-3,:newest =>-4}#我的求职，我的推荐

  Tab_1 = [Menu::TYPES[:company_profile], Menu::TYPES[:nothing]]
  Tab_2 = [Menu::TYPES[:positions],  Menu::TYPES[:all_pos], Menu::TYPES[:newest_pos]]
  Tab_3 = [TYPES[:my_resume],Menu::TYPES[:outside_link], Menu::TYPES[:my_recommend], Menu::TYPES[:my_jobs]]
  scope :one_level, ->{where("parent_id = 0")}
  NO_TEMP = 0   #没有关联任何简介、职位、模板时temp_id为0
  PARENT_ID = 0 #父菜单parent_id 为0
  type_names_arr.each do |type|
    scope type, :conditions => { :types => TYPES[type] }
    define_method  "#{type.to_s}?" do
      self.types == TYPES[type]
    end
  end

  def children
    Menu.where({:company_id => company_id, :parent_id => id})
  end

end