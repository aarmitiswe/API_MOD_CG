class CreateJobLanguages < ActiveRecord::Migration
  def change
    create_table :job_languages do |t|
      t.references :job, index: true, foreign_key: :job_id
      t.references :language, index: true, foreign_key: :language_id

      t.timestamps null: false
    end
  end
end
