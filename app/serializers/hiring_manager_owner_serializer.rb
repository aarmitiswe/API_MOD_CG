class HiringManagerOwnerSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :hiring_manager_id, :name, :role

  def name
    object.user.full_name
  end

  def role
    object.user.role
  end
end
