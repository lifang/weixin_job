class AddWeixinAppIdAndAppSecretToCompany < ActiveRecord::Migration
  def change
    add_column :companies, :app_id, :string   #微信用于获取access_token的 app_id
    add_column :companies, :app_secret, :string   #微信 用于获取access_token的 app_secret
  end
end
