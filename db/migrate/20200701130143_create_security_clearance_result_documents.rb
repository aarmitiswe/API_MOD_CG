class CreateSecurityClearanceResultDocuments < ActiveRecord::Migration
  def change
    create_table :security_clearance_result_documents do |t|
      t.references :job_application, index: true
      t.string :title
      t.string :file_path
      t.boolean :default
      t.boolean :is_deleted
      t.attachment :document

      t.timestamps null: false
    end

    add_column :job_applications, :security_clearance_result_document_id, :integer
  end
end
