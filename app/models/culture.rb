class Culture < ActiveRecord::Base
  belongs_to :company

  validates_presence_of :title, :avatar, :company

  has_attached_file :avatar, dependent: :destroy

  validates_attachment_content_type :avatar, content_type: ["image/jpg", "image/jpeg", "image/png", "image/gif", "image/bmp"]

  def upload_avatar new_avatar
    self.avatar = new_avatar
    self.save!
  end
end
