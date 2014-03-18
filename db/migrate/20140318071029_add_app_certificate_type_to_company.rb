class AddAppCertificateTypeToCompany < ActiveRecord::Migration
  def change
    add_column :companies, :app_service_certificate, :boolean, :default => false
  end
end
