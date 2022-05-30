class CreateJobTags < ActiveRecord::Migration
  def change
    create_table :job_tags do |t|
      t.references :job, index: true, foreign_key: :job_id
      t.references :tag, index: true, foreign_key: :tag_id

      t.timestamps null: false
    end
  end
end
