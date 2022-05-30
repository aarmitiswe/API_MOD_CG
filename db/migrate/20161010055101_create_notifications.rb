class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.references :user, index: true, foreign_key: :user_id
      t.integer :blog
      t.integer :poll_question
      t.integer :job

      t.timestamps null: false
    end
  end
end
