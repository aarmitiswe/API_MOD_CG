class AddAttachmentDocumentToJobseekerResumes < ActiveRecord::Migration
  def self.up
    change_table :jobseeker_resumes do |t|
      t.attachment :document
    end
  end

  def self.down
    remove_attachment :jobseeker_resumes, :document
  end
end
