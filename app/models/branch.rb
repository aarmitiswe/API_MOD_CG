class Branch < ActiveRecord::Base
  include Pagination
  belongs_to :company
  has_many :jobs


  has_attached_file :avatar, dependent: :destroy

  validates_attachment_content_type :avatar, content_type: ["image/jpg", "image/jpeg", "image/png", "image/gif", "image/bmp", "image/svg+xml"]




  has_attached_file :ar_avatar, dependent: :destroy

  validates_attachment_content_type :ar_avatar, content_type: ["image/jpg", "image/jpeg", "image/png", "image/gif", "image/bmp", "image/svg+xml"]



#   TODO: This for copy old avatars
  UploadAvatar = Struct.new(:branch, :avatar_local_path, :ar_avatar_local_path) do
    def perform
      branch.avatar = File.open(avatar_local_path)
      branch.ar_avatar = File.open(ar_avatar_local_path)
      branch.save
    end
  end
end
