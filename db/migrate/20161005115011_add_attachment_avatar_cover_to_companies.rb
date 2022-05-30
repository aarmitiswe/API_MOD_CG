class AddAttachmentAvatarCoverToCompanies < ActiveRecord::Migration
  def self.up
    change_table :companies do |t|
      t.attachment :avatar
      t.attachment :cover
    end
  end

  def self.down
    remove_attachment :companies, :avatar
    remove_attachment :companies, :cover
  end
end
