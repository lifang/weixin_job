class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.integer :company_id
      t.integer :from_user
      t.integer :to_user
      t.integer :types
      t.text :content
      t.boolean :status , :default => false
      t.string :msg_id
      t.integer :message_type , :default => 0
      t.string :message_path

      t.timestamps
    end
    
    add_index :messages, :msg_id, :unique => true, :name => 'by_msg_id'
  end
end
