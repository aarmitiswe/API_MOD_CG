class CreateJobseekerLanguages < ActiveRecord::Migration
  def change
    create_table :jobseeker_languages do |t|
      t.references :jobseeker, index: true, foreign_key: :jobseeker_id
      t.references :language, index: true, foreign_key: :language_id

      t.timestamps null: false
    end
  end
end
