class LikeBlogSerializer < ActiveModel::Serializer
  delegate :current_user, to: :scope

  attributes :id, :likes_count, :is_liked_by_current_user

  def likes_count
    object.likes.count
  end

  def is_liked_by_current_user
    object.is_like_by_user(current_user)
  end
end
