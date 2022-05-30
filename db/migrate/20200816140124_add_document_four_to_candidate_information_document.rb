class AddDocumentFourToCandidateInformationDocument < ActiveRecord::Migration
  def change
    add_attachment :candidate_information_documents, :document_four
  end
end
