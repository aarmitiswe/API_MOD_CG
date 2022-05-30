class CreateJobseekerTags < ActiveRecord::Migration
  def change
    create_table :jobseeker_tags do |t|
      t.references :tag, index: true, foreign_key: true
      t.references :jobseeker, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
