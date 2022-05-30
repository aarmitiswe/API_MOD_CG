class AddStatusToCandidateInformationDocument < ActiveRecord::Migration
  def change
    add_column :candidate_information_documents, :status, :string
  end
end
