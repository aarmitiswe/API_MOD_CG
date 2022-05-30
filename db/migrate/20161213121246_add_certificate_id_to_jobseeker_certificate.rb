class AddCertificateIdToJobseekerCertificate < ActiveRecord::Migration
  def change
    add_reference :jobseeker_certificates, :certificate, index: true, foreign_key: :certificate_id
  end
end
