class CreateBlogs < ActiveRecord::Migration
  def change
    create_table :blogs do |t|
      t.string :title
      t.text :description
      t.boolean :is_active
      t.boolean :is_deleted
      t.attachment :avatar
      t.attachment :video
      t.string :video_link
      t.string :image_file
      t.integer :views_count
      t.integer :downloads_count
      t.references :company_user, index: true, foreign_key: :company_user_id

      t.timestamps null: false
    end
  end
end
