class CreateJobseekerRequiredDocuments < ActiveRecord::Migration
    def change
        create_table :jobseeker_required_documents do |t|
          t.string :document_type
          t.attachment :document
          t.references :job_application_status_change, index: {name: :index_jobseeker_required_doc_on_job_app_status_change_id}, foreign_key: :job_application_status_change_id
          t.string :status

          t.timestamps null: false
        end
    end
end