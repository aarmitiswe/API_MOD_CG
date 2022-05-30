class CreateJobseekerGraduatePrograms < ActiveRecord::Migration
  def change
    create_table :jobseeker_graduate_programs do |t|
      t.decimal :ielts_score
      t.attachment :ielts_document
      t.decimal :toefl_score
      t.attachment :toefl_document
      t.decimal :age
      t.decimal :bachelor_gpa
      t.decimal :master_gpa

      t.references :nationality
      t.references :jobseeker, index: true, foreign_key: :jobseeker_id

      t.timestamps null: false
    end
  end
end
