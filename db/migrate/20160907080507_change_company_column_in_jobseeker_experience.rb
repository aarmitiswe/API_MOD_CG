class ChangeCompanyColumnInJobseekerExperience < ActiveRecord::Migration
  def change
    rename_column :jobseeker_experiences, :company, :company_name
    add_reference :jobseeker_experiences, :company, index: true, foreign_key: :company_id
  end
end
