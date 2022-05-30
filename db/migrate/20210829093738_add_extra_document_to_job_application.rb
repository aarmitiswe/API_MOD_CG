class AddExtraDocumentToJobApplication < ActiveRecord::Migration
  def self.up
    change_table :job_applications do |t|
      t.attachment :extra_document
    end
    add_column :job_applications, :extra_document_title, :string
  end

  def self.down
    remove_attachment :job_applications, :extra_document
    remove_column :job_applications, :extra_document_title
  end
end
