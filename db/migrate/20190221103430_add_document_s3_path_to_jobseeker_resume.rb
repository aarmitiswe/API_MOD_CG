class AddDocumentS3PathToJobseekerResume < ActiveRecord::Migration
  def change
    add_column :jobseeker_resumes, :document_s3_path, :string
  end
end
