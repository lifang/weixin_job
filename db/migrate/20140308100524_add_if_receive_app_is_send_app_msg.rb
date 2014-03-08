class AddIfReceiveAppIsSendAppMsg < ActiveRecord::Migration
  def change
    add_column :companies, :is_send_app_msg ,:boolean
    add_column :companies, :receive_status, :boolean, :default => false
    add_column :companies , :not_receive_start_at , :datetime
    add_column :companies , :not_receive_end_at , :datetime
  end

end
