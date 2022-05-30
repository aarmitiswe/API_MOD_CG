class BoardingRequisitionSerializer < ActiveModel::Serializer
  attributes :id, :status, :comment
  has_one :user
end
