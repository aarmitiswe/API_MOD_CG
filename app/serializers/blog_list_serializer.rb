class BlogListSerializer < ActiveModel::Serializer
  delegate :current_user, to: :scope

  attributes :id, :title, :is_active, :avatar, :views_count, :downloads_count,
             :comments_count, :likes_count, :author, :created_at, :is_liked_by_current_user

  def comments_count
    object.comments.active.count
  end

  def likes_count
    object.likes.count
  end

  def is_liked_by_current_user
    object.is_like_by_user(current_user)
  end

  def author
    {
        id: object.company_user.company_id,
        name: object.company_user.company.name,
        avatar: object.company_user.company.avatar
    }
  end
end
