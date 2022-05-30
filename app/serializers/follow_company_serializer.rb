class FollowCompanySerializer < ActiveModel::Serializer
  delegate :current_user, to: :scope

  attributes :id,  :followers_count, :is_followed_by_current_user

  def is_followed_by_current_user
    object.is_follow_by_user(current_user)
  end
end
