class AddTokenToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :token, :string
    add_index :companies, :token
  end
end
