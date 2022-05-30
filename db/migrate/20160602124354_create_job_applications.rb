class CreateJobApplications < ActiveRecord::Migration
  def change
    create_table :job_applications do |t|

      t.references :user, index: true
      t.references :job, index: true
      t.references :job_application_status, index: true
      t.references :jobseeker_coverletter, index: true
      t.references :jobseeker_resume, index: true

      t.timestamps null: false
    end
    add_foreign_key :job_applications, :users
    add_foreign_key :job_applications, :jobs
    add_foreign_key :job_applications, :job_application_statuses
    add_foreign_key :job_applications, :jobseeker_coverletters
    add_foreign_key :job_applications, :jobseeker_resumes

  end
end
