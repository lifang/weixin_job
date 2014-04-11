class AddColumnToClientResumes < ActiveRecord::Migration
  def change
    add_column :delivery_resume_records , :join_time,:datetime
    add_column :delivery_resume_records , :join_addr,:string
    add_column :delivery_resume_records , :join_remark,:string
    add_column :client_resumes,:clint_name,:string
    add_column :client_resumes,:client_phone,:string
  end
end
