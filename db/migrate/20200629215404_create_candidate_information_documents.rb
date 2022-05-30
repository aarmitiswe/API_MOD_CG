class CreateCandidateInformationDocuments < ActiveRecord::Migration
  def change
    create_table :candidate_information_documents do |t|
      t.references :job_application, index: true
      t.string :title
      t.string :file_path
      t.boolean :default
      t.boolean :is_deleted
      t.attachment :document

      t.timestamps null: false
    end

  end

end
