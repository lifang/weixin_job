class ChangeColumnType < ActiveRecord::Migration
  def up
    change_column :positions , :description , :text
  end

  def down
  end
end
