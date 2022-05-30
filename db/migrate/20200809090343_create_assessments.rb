class CreateAssessments < ActiveRecord::Migration
  def change
    create_table :assessments do |t|
      t.string :assessment_type
      t.string :status
      t.text :comment
      t.attachment :document_report
      t.references :user, index: true
      t.references :job_application_status_change, index: true
      t.timestamps null: false
    end
  end
end
