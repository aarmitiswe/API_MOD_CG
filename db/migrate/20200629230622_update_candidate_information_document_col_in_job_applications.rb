class UpdateCandidateInformationDocumentColInJobApplications < ActiveRecord::Migration
  def change
    remove_column :job_applications, :candidate_information_document
    add_column :job_applications, :candidate_information_document_id, :integer
  end
end
