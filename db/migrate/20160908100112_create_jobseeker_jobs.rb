class CreateJobseekerJobs < ActiveRecord::Migration
  def change
    create_table :jobseeker_jobs do |t|
      t.references :jobseeker, index: true, foreign_key: :jobseeker_id
      t.references :job, index: true, foreign_key: :job_id

      t.timestamps null: false
    end
  end
end
