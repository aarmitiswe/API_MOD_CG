class AddAttachmentDocumentToJobseekerCoverletters < ActiveRecord::Migration
  def self.up
    change_table :jobseeker_coverletters do |t|
      t.attachment :document
    end
  end

  def self.down
    remove_attachment :jobseeker_coverletters, :document
  end
end
