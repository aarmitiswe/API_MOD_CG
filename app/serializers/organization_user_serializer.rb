class OrganizationUserSerializer < ActiveModel::Serializer
  attributes :id, :is_manager
  has_one :organization
  has_one :user
end
