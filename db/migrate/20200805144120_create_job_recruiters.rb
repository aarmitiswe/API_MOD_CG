class CreateJobRecruiters < ActiveRecord::Migration
  def change
    create_table :job_recruiters do |t|
      t.references :job, references: :job_recruiters
      t.references :user, references: :job_recruiters

      t.timestamps null: false
    end
  end
end
