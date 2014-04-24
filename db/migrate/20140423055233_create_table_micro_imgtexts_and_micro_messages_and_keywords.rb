class CreateTableMicroImgtextsAndMicroMessagesAndKeywords < ActiveRecord::Migration
  def change
    create_table :micro_messages do |t|
      t.integer :company_id
      t.boolean :mtype  #图文/文字
      t.boolean :solid_link_flag  #是否是app登记的链接

      t.timestamps
    end

    add_index :micro_messages, :mtype

    create_table :keywords do |t|
      t.integer :company_id
      t.string :keyword
      t.integer :micro_message_id
      t.boolean :types  #关键字回复/自动回复
      t.timestamps
    end
    add_index :keywords, :keyword
    add_index :keywords, :types
    add_index :keywords, :micro_message_id

    create_table :micro_imgtexts do |t|
      t.string :title
      t.string :img_path
      t.text :content
      t.string :url
      t.integer :micro_message_id

      t.timestamps
    end

    add_index :micro_imgtexts, :micro_message_id
  end
end
