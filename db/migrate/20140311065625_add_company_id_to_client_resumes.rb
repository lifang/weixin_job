class AddCompanyIdToClientResumes < ActiveRecord::Migration
  def change
    add_column :client_resumes, :company_id, :integer

  end
end
