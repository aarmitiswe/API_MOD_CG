class AddVideoCoverScreenshotToCompany < ActiveRecord::Migration
  def self.up
      change_table :companies do |t|
        t.attachment :video_cover_screenshot
      end
  end

  def self.down
      remove_attachment :companies, :video_cover_screenshot
  end
end