class CreateDeliveryResumeRecords < ActiveRecord::Migration
  def change
    create_table :delivery_resume_records do |t|
      t.integer :company_id, :null => false
      t.integer :position_id, :null => false
      t.integer :client_resume_id, :null => false
      t.timestamps
    end
  end
end
