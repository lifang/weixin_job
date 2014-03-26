class AddIndexToClientOpenId < ActiveRecord::Migration
  def change
    add_index :clients, :open_id, :unique => true, :name => 'by_open_id'
  end
end
