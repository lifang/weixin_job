class AddAppTypeToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :app_type, :integer
  end
end
