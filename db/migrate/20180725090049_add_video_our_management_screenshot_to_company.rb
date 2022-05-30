class AddVideoOurManagementScreenshotToCompany < ActiveRecord::Migration
  def self.up
    change_table :companies do |t|
      t.attachment :video_our_management_screenshot
    end
  end

  def self.down
    remove_attachment :companies, :video_our_management_screenshot
  end
end
