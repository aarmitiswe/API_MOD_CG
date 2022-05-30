class AddEmpTypeAndCandidateTypeToJobseeker < ActiveRecord::Migration
  def change
    add_column :jobseekers, :employment_type, :string
    add_column :jobseekers, :candidate_type, :string
  end
end
