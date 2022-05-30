class AddDocumentsToCandidateInformationDocument < ActiveRecord::Migration
  def change
    add_attachment :candidate_information_documents, :document_two
    add_attachment :candidate_information_documents, :document_three
    add_column :candidate_information_documents, :name, :string
    add_column :candidate_information_documents, :id_number, :string
    add_column :candidate_information_documents, :job_title, :string
    add_column :candidate_information_documents, :job_grade, :string
    add_column :candidate_information_documents, :agency_id, :string
    add_column :candidate_information_documents, :current_employer, :string
    add_reference :candidate_information_documents, :job_application_status_change, index: true, foreign_key: true, index: { name: 'can_doc_index'}
  end
end
