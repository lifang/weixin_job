class AddFakerIdToClientsAndRemoveTokenFromCwebAndAddTokenToClients < ActiveRecord::Migration
  def change
    add_column :clients, :faker_id, :string  #微信后台页面关注者对应的faker_id
    add_column :clients, :token, :string  #ipone 手机识别用到的token
    add_column :clients, :wx_cookie, :string #保存模拟登录用的cookie
    add_column :clients, :wx_login_token, :string #保存模拟登录用的token
    remove_column :companies, :token  #删除companies表里面的token字段，这个字段与cweb字段重复了
    change_column :clients, :has_new_message, :boolean, :default => false #设置默认值
    change_column :clients, :has_new_record, :boolean, :default => false #设置默认值
  end
end
