class CompanyMember < ActiveRecord::Base
  include VideoUpload
  belongs_to :company


  has_attached_file :video, dependent: :destroy

  validates_attachment_content_type :video, content_type: ['video/x-msvideo', 'video/avi', 'video/quicktime',
                                                           'video/3gpp', 'video/x-ms-wmv', 'video/mp4',
                                                           'flv-application/octet-stream', 'video/x-flv',
                                                           'video/mpeg', 'video/mpeg4', 'video/x-la-asf',
                                                           'video/x-ms-asf', 'flv-application/octet-stream',
                                                           'video/flv', 'video/webm']

  has_attached_file :video_screenshot, dependent: :destroy

  validates_attachment_content_type :video_screenshot, content_type: ["image/jpg", "image/jpeg", "image/png", "image/gif", "image/bmp"]

  has_attached_file :avatar, dependent: :destroy

  validates_attachment_content_type :avatar, content_type: ["image/jpg", "image/jpeg", "image/png", "image/gif", "image/bmp"]

  validates_presence_of :name, :position

  def upload_avatar image_file
    self.avatar = image_file
    self.save!
  end

  def delete_avatar
    self.avatar = nil
    self.save!
  end

  def delete_video
    self.video = nil
    self.save!
  end
end
