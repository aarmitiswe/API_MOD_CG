class CreateBlogTags < ActiveRecord::Migration
  def change
    create_table :blog_tags do |t|
      t.references :blog, index: true, foreign_key: :blog_id
      t.references :tag, index: true, foreign_key: :tag_id

      t.timestamps null: false
    end
  end
end
