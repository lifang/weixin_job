#encoding: utf-8
class Company < ActiveRecord::Base
  extend ApplicationHelper
  has_many :position_types
  has_many :positions
  has_many :work_addresses
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
  has_many :keywords ,dependent: :destroy
  has_many :micro_messages ,dependent: :destroy

  validate :name, :uniqueness => true, :allow_nil => false, :message => "该公司名称已被注册!"
  validate :company_account, :uniqueness => true, :allow_nil => false, :message => "该用户名已被注册!"

  STATUS = {:DELETED => 0, :NORMAL => 1}  #状态0删除，1正常
  HAS_APP = {:NO => false, :YES => true} #是否有APP
  APP_TYPE = {:SUBSCRIPTION => 0, :SERVICE => 1} #公众号类型0订阅号，1服务号
  APP_CERTIFICATED_TYPE = {:YES => 1, :NO => 0} #公众号类型0订阅号，1服务号

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
              {:type => "view", :name => sm.name, :url => sm.file_path.present? ? (sm.file_path.include?("http://") ? sm.file_path : ApplicationHelper::MW_URL + sm.file_path.to_s) : ""}:
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
        if template_name == 'company_profile'
           one_level_menu = {:type => "view",
            :name => om.name,
            :url => om.file_path.present? ? (om.file_path.include?("http://") ? om.file_path : ApplicationHelper::MW_URL + om.file_path.to_s) : ""
          }
        else
          one_level_menu = {:type => "click",
            :name => om.name,
            :key => "#{template_name}_#{om.temp_id}"
          }
        end

      end

      menu_hash[:button] << one_level_menu
    end
    menu_hash = menu_hash.to_json.gsub!(/\\u([0-9a-z]{4})/) {|s| [$1.to_i(16)].pack("U")}
    menu_hash
  end

  def self.get_client_infos_by company_id,start_time,end_time
    sql = "select clf.id,clf.resume_template_id,clf.html_content_datas,clf.has_completed,clf.created_at,clf.updated_at from companies c
           right join resume_templates cl on c.id=cl.company_id
           right join client_resumes clf  on cl.id = clf.resume_template_id
           where c.id = ? and clf.created_at >=? and clf.created_at <=?"
    Company.find_by_sql([sql,company_id,start_time,end_time])
  end


  #同步旧的关注者的信息
  def synchronize_old_client_data
    if self.service_account? && self.app_service_certificate #是服务号并且是认证的
      #请求api
      access_token = Company.get_access_token(self)#在helpers/weixin.rb
      if access_token && access_token["access_token"]
        access_token_val = access_token["access_token"]
        Company.service_account_get_user_list(access_token_val, self)
      end
    else
      #请求公众号后台用户列表
      login_info = Company.login_to_weixin(self)#在helpers/weixin.rb
      if login_info.present?
        wx_token, wx_cookie = login_info
        Company.get_friend_list(wx_cookie, wx_token, self)
      end
    end
    Client.find_each do |client|
      client.give_client_a_name
    end
  end
end
