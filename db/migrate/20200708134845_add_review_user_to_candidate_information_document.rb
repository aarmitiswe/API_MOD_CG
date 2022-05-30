class AddReviewUserToCandidateInformationDocument < ActiveRecord::Migration
  def change
    add_reference :candidate_information_documents, :user, index: true, foreign_key: true
  end
end
