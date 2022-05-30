class BlogSerializer < ActiveModel::Serializer
  delegate :current_user, to: :scope

  attributes :id, :title, :description, :is_active, :is_deleted, :avatar, :views_count, :downloads_count,
             :image_file, :comments_count, :likes_count, :is_liked_by_current_user, :author, :created_at,
             :current_user_avatar

  has_many :comments
  has_many :blog_tags, root: :tags

  def comments_count
    object.comments.active.count
  end

  def comments
    return [] unless current_user
    object.comments.active
  end

  def likes_count
    object.likes.count
  end

  def is_liked_by_current_user
    object.is_like_by_user(current_user)
  end

  def author
    return {} if object.company_user.nil?
    {
        id: object.company_user.company_id,
        name: object.company_user.company.name,
        avatar: object.company_user.company.avatar
    }
  end

  def current_user_avatar
    return nil unless current_user
    current_user.avatar
  end
end
