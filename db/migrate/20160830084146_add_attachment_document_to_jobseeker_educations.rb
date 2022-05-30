class AddAttachmentDocumentToJobseekerEducations < ActiveRecord::Migration
  def self.up
    change_table :jobseeker_educations do |t|
      t.attachment :document
    end
  end

  def self.down
    remove_attachment :jobseeker_educations, :document
  end
end
