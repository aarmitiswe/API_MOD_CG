class AddAttachmentDocumentToJobseekerCertificates < ActiveRecord::Migration
  def self.up
    change_table :jobseeker_certificates do |t|
      t.attachment :document
    end
  end

  def self.down
    remove_attachment :jobseeker_certificates, :document
  end
end
