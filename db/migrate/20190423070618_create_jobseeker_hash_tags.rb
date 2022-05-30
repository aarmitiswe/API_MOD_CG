class CreateJobseekerHashTags < ActiveRecord::Migration
  def change
    create_table :jobseeker_hash_tags do |t|
      t.references :jobseeker, index: true, foreign_key: :jobseeker_id
      t.references :hash_tag, index: true, foreign_key: :hash_tag_id

      t.timestamps null: false
    end
  end
end
