class AddColumnToDelivery < ActiveRecord::Migration
  def change
    add_column :delivery_resume_records , :recomender_id , :string
    add_index :delivery_resume_records, :recomender_id
  end
end
