class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.string :content
      t.boolean :is_deleted
      t.boolean :is_active
      t.references :user, index: true, foreign_key: :user_id
      t.references :blog, index: true, foreign_key: :blog_id

      t.timestamps null: false
    end
  end
end
