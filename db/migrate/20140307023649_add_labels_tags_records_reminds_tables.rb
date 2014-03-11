class AddLabelsTagsRecordsRemindsTables < ActiveRecord::Migration
  def change
    #创建标签用户关系表
    create_table :labels do |t|
      t.integer :company_id
      t.integer :tag_id
      t.integer :client_id

      t.timestamps
    end
    add_index :labels,:company_id
    add_index :labels,:tag_id
    add_index :labels,:client_id

    # 创建标签表
    create_table :tags do |t|
      t.string :content

      t.timestamps
    end

    #创建提醒表
    create_table :reminds do |t|
      t.integer :company_id
      t.string :content
      t.date :reseve_time
      t.string :title
      t.boolean :range
      t.integer :days

      t.timestamps
    end
    add_index :reminds, :company_id

    #创建记录表
    create_table :records do |t|
      t.integer :company_id
      t.text :content
      t.string :title

      t.timestamps
    end

    add_index :records, :company_id

  end
end
