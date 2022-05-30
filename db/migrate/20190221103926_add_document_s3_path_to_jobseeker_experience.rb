class AddDocumentS3PathToJobseekerExperience < ActiveRecord::Migration
  def change
    add_column :jobseeker_experiences, :document_s3_path, :string
  end
end
