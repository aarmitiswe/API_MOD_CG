class AddAttachmentDocumentToJobseekerExperiences < ActiveRecord::Migration
  def self.up
    change_table :jobseeker_experiences do |t|
      t.attachment :document
    end
  end

  def self.down
    remove_attachment :jobseeker_experiences, :document
  end
end
