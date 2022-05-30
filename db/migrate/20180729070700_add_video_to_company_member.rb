class AddVideoToCompanyMember < ActiveRecord::Migration
  def self.up
      change_table :company_members do |t|
        t.attachment :video
      end
  end

  def self.down
      remove_attachment :company_members, :video
  end
end
