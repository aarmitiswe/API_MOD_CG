class AddAttachmentDocumentESignatureToCompanyUsers < ActiveRecord::Migration
  def self.up
    change_table :company_users do |t|
      t.attachment :document_e_signature
    end
  end

  def self.down
    remove_attachment :company_users, :document_e_signature
  end
end
