class Blog < ActiveRecord::Base
  include VideoUpload
  include Pagination
  include EmployerJobseekerWeight
  
  belongs_to :company_user
  has_many :blog_tags, dependent: :destroy
  has_many :tags, through: :blog_tags
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy

  validates_presence_of :title, :description


  has_attached_file :video, dependent: :destroy

  validates_attachment_content_type :video, content_type: ['video/x-msvideo', 'video/avi', 'video/quicktime',
                                                           'video/3gpp', 'video/x-ms-wmv', 'video/mp4',
                                                           'flv-application/octet-stream', 'video/x-flv',
                                                           'video/mpeg', 'video/mpeg4', 'video/x-la-asf',
                                                           'video/x-ms-asf', 'flv-application/octet-stream',
                                                           'video/flv', 'video/webm']

  # No Need medium: "400x400>", thumb: "150x150>"
  has_attached_file :avatar, dependent: :destroy

  validates_attachment_content_type :avatar, content_type: ["image/jpg", "image/jpeg",
                                                            "image/png", "image/gif", "image/bmp"]

  validates_presence_of :title, :description, :company_user_id

  scope :active, -> { where(is_active: true, is_deleted: false) }
  scope :deleted, -> { where(is_deleted: true) }
  scope :order_by_date, -> { order(created_at: :desc) }
  scope :order_by_views, -> { order(views_count: :desc) }
  # Left Join to get all blogs that has/hasn't comments
  scope :order_by_comments, -> { joins("LEFT JOIN comments ON comments.blog_id = blogs.id").group("blogs.id")
                                     .order("count(comments.id) DESC NULLS LAST") }

  # tags are [{id: 1, name: "CCNA"}, {id: null, name: "ICDL"}]
  def add_tags new_tags
    return true if new_tags.nil?

    exist_blog_tag_ids = []
    new_tag_ids = []

    new_tags.each do |tag|
      tag_type = TagType.find_by_name("Blogs")
      new_tag = if tag[:id].nil? || tag[:id] == "null"
                          Tag.find_or_create_by(name: tag[:name], tag_type_id: tag_type.id)
                        else
                          Tag.find_by_id(tag[:id])
                        end

      unless self.tag_ids.include?(new_tag.id)
        weight = new_tag.weight || 0
        new_tag.update_attribute(:weight, weight + Blog::EMPLOYER_WEIGHT)

        new_tag_ids.push({blog_id: self.id, tag_id: new_tag.id})
      else
        exist_blog_tag_ids.push(BlogTag.find_by(blog_id: self.id, tag_id: new_tag.id).id)
      end
    end
    #  Delete associated tags
    deleted_blog_tag_ids = self.blog_tag_ids - exist_blog_tag_ids

    BlogTag.where(id: deleted_blog_tag_ids).destroy_all

    # Create new job_tags
    BlogTag.create(new_tag_ids)
  end
  
  def upload_avatar new_avatar
    self.avatar  = new_avatar
    self.save!
  end

  def author
    self.company_user.company
  end

  def owner
    self.author.owner
  end

  def is_like_by_user user
    !user.nil? && !Like.find_by(blog_id: self.id, user_id: user.id).nil?
  end

  def increase_viewers
    self.views_count ||= 0
    self.views_count += 1
    self.save(validate: false)
  end

  def increase_downloader
    self.downloads_count ||= 0
    self.downloads_count += 1
    self.save
  end

  UploadAvatar = Struct.new(:blog, :file_path) do
    def perform
      blog.avatar = File.open(file_path)
      blog.save
    end
  end
end
