class CreateLikes < ActiveRecord::Migration
  def change
    create_table :likes do |t|
      t.references :user, index: true, foreign_key: :user_id
      t.references :blog, index: true, foreign_key: :blog_id

      t.timestamps null: false
    end
  end
end
