class AddAttachmentAvatarToCompanyMembers < ActiveRecord::Migration
  def self.up
    change_table :company_members do |t|
      t.attachment :avatar
    end
  end

  def self.down
    remove_attachment :company_members, :avatar
  end
end
