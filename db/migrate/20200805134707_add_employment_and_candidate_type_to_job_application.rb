class AddEmploymentAndCandidateTypeToJobApplication < ActiveRecord::Migration
  def change
    add_column :job_applications, :employment_type, :string
    add_column :job_applications, :candidate_type, :string
  end
end
