class ChangeColumnOfMobiephoneOfClientsTable < ActiveRecord::Migration
  def change
    change_column :clients, :mobiephone, :string, :limit => 45
  end
end
