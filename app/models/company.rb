#encoding: utf-8
class Company < ActiveRecord::Base
  has_many :position_types
  has_many :positions
  has_many :resume_templates
  has_many :delivery_resume_records
  has_many :company_profiles
  has_many :clients
  has_many :tags
  has_many :labels
  has_many :reminds
  has_many :records
  #scope  :clients, -> { where("types = #{Client::TYPES[:CONCERNED]}") }
  #scope  :client, -> { where("types = #{Client::TYPES[:ADMIN]}") }
  has_many :menus

  validate :name, :uniqueness => true, :allow_nil => false, :message => "该公司名称已被注册!"
  validate :company_account, :uniqueness => true, :allow_nil => false, :message => "该用户名已被注册!"

  STATUS = {:DELETED => 0, :NORMAL => 1}  #状态0删除，1正常
  HAS_APP = {:NO => false, :YES => true} #是否有APP
  APP_TYPE = {:SUBSCRIPTION => 0, :SERVICE => 1} #公众号类型0订阅号，1服务号

  def subscribed_account?
    self.app_type == APP_TYPE[:SUBSCRIPTION]
  end

  def service_account?
    self.app_type == APP_TYPE[:SERVICE]
  end


  #根据company获取自定义菜单
  def get_menu_by_website
    one_level_menus = self.menus.one_level
    menu_hash = {:button => []}
    one_level_menus.each do |om|
      this_second_menus = om.children
      if this_second_menus.present? #如果有二级菜单
        second_level_menu = [] #二级菜单
        this_second_menus.each do |sm|
          template_name = Menu::TYPE_NAMES[sm.types]
          second_level_menu << (template_name == "company_profile" ?
              {:type => "view", :name => sm.name, :url => ApplicationHelper::MW_URL + sm.file_path}:
              {:type => "click", :name => sm.name, :key => "#{template_name}_#{sm.temp_id}" })
        end
        #一级菜单
        one_level_menu = {:type => "click",
          :name => om.name,
          :sub_button => second_level_menu
        }
      else  #如果没有二级菜单
        #一级菜单
        template_name = Menu::TYPE_NAMES[om.types]
        one_level_menu = {:type => "click",
          :name => om.name,
          :key => "#{template_name}_#{om.temp_id}"
        }
      end

      menu_hash[:button] << one_level_menu
    end
    menu_hash = menu_hash.to_json.gsub!(/\\u([0-9a-z]{4})/) {|s| [$1.to_i(16)].pack("U")}
    menu_hash
  end

  def self.get_client_infos_by company_id,start_time,end_time
    sql = "select clf.id,clf.client_id,clf.hash_content,clf.created_at,clf.updated_at from companies c
           right join clients cl on c.id=cl.company_id
           right join client_html_infos clf on cl.id = clf.client_id
           where c.id = ? and clf.created_at >=? and clf.created_at <=?"
    Company.find_by_sql([sql,company_id,start_time,end_time])
  end
end
