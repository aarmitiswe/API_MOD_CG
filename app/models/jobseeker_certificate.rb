class JobseekerCertificate < ActiveRecord::Base
  include DocumentUpload

  belongs_to :jobseeker
  belongs_to :certificate

  # validates_presence_of :name, :jobseeker_id
  validates_presence_of :name

  UploadDocument = Struct.new(:jobseeker_certificate, :document_local_path) do
    def perform
      jobseeker_certificate.document = File.open(document_local_path)
      jobseeker_certificate.save
    end
  end
end
