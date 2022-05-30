class AddVideoScreenshotToCompanyMember < ActiveRecord::Migration
  def self.up
      change_table :company_members do |t|
        t.attachment :video_screenshot
      end
  end

  def self.down
      remove_attachment :company_members, :video_screenshot
    end
end
