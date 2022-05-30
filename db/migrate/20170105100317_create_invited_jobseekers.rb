class CreateInvitedJobseekers < ActiveRecord::Migration
  def change
    create_table :invited_jobseekers do |t|
      t.references :jobseeker, index: true, foreign_key: :jobseeker_id
      t.references :job, index: true, foreign_key: :job_id
      t.string :msg_content

      t.timestamps null: false
    end
  end
end
