class RemoveLevelToMenus < ActiveRecord::Migration
  def change
    remove_column :menus, :level
  end
end
