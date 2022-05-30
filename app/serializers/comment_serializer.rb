class CommentSerializer < ActiveModel::Serializer
  attributes :id, :content, :is_deleted, :is_active, :created_at
  has_one :user

  def user
    {id: object.user.id, name: object.user.full_name}
  end
end
