class AddColumnToDeliveryResumeRecords < ActiveRecord::Migration
  def change
    add_column :delivery_resume_records , :status ,:integer , :default=>0
    add_column :delivery_resume_records , :audition_time,:datetime
    add_column :delivery_resume_records , :audition_addr,:string
    add_column :delivery_resume_records , :remark,:string
  end
end
