class AddReportDocumentToCandidateInformationDocument < ActiveRecord::Migration
  def change
    add_attachment :candidate_information_documents, :document_report
  end
end
