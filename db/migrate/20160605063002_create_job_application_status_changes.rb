class CreateJobApplicationStatusChanges < ActiveRecord::Migration
  def change
    create_table :job_application_status_changes do |t|
      t.references :job_application
      t.references :job_application_status
      t.references :employer, references: :users
      t.references :jobseeker, references: :users
      t.string :comment

      t.timestamps null: false
    end
    add_foreign_key :job_application_status_changes, :job_applications
    add_foreign_key :job_application_status_changes, :job_application_statuses
    add_foreign_key :job_application_status_changes, :users, column: :employer_id
    add_foreign_key :job_application_status_changes, :users, column: :jobseeker_id
  end
end
