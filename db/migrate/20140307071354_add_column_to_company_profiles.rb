class AddColumnToCompanyProfiles < ActiveRecord::Migration
  def change
    add_column :company_profiles , :title , :string
    add_column :company_profiles , :file_path , :string
  end
end
