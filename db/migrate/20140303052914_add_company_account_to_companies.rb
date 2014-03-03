class AddCompanyAccountToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :company_account, :string, :null => false
    add_column :companies, :company_password, :string, :null => false

  end
end
