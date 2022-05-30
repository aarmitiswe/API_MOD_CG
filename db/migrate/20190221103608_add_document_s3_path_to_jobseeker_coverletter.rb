class AddDocumentS3PathToJobseekerCoverletter < ActiveRecord::Migration
  def change
    add_column :jobseeker_coverletters, :document_s3_path, :string
  end
end
