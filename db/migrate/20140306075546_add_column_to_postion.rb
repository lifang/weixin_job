class AddColumnToPostion < ActiveRecord::Migration
  def change
     add_column :positions , :position_type_id , :integer
  end
end
