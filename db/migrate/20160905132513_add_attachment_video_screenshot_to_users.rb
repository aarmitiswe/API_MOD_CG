class AddAttachmentVideoScreenshotToUsers < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.attachment :video_screenshot
    end
  end

  def self.down
    remove_attachment :users, :video_screenshot
  end
end
