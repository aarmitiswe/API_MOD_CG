class AddDocumentS3PathToJobseekerCertificate < ActiveRecord::Migration
  def change
    add_column :jobseeker_certificates, :document_s3_path, :string
  end
end
