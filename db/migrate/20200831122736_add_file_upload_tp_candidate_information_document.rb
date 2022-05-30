class AddFileUploadTpCandidateInformationDocument < ActiveRecord::Migration
  def change
    add_attachment :candidate_information_documents, :document_passport
    add_attachment :candidate_information_documents, :document_edu_cert
    add_attachment :candidate_information_documents, :document_national_address
    add_attachment :candidate_information_documents, :document_training_cert
  end
end
