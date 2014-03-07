class AddCompanyIdAndTypeAndFilePathToMenus < ActiveRecord::Migration
  def change
    add_column :menus, :company_id, :integer #company 外键
    add_column :menus, :types, :integer  #菜单类型（公司简介，职位，简历）
    add_column :menus, :file_path, :string  #文件路径
  end
end
