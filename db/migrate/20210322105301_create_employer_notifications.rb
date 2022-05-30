class CreateEmployerNotifications < ActiveRecord::Migration
  def change
    create_table :employer_notifications do |t|
      t.integer :notifiable_id
      t.string :notifiable_type
      t.references :user, index: true, foreign_key: true
      t.string :finished_action
      t.string :needed_action
      t.references :email_template, index: true, foreign_key: true
      t.string :subject
      t.text :content
      t.string :status
      t.string :page_url

      t.timestamps null: false
    end
  end
end
