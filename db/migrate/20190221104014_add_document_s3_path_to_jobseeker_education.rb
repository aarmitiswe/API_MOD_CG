class AddDocumentS3PathToJobseekerEducation < ActiveRecord::Migration
  def change
    add_column :jobseeker_educations, :document_s3_path, :string
  end
end
