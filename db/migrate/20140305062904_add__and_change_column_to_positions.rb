class AddAndChangeColumnToPositions < ActiveRecord::Migration
  def change
    remove_column :positions,:position_type_id
    add_column :positions , :menu_id , :integer
    add_column :positions , :company_id ,:integer
  end
end
