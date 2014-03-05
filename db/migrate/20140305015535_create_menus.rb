class CreateMenus < ActiveRecord::Migration
  def change
    create_table :menus do |t|
      t.string :name
      t.integer :temp_id
      t.integer :level, :default => 1
      t.integer :parent_id, :default => 0
      t.timestamps
    end
  end
end
