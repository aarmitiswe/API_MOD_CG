class AddCandidateInformationColsTobApplication < ActiveRecord::Migration
  def change
    add_column :job_applications, :candidate_information_document, :string
  end
end
