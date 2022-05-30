class OfferApproverSerializer < ActiveModel::Serializer
  attributes :id, :level
  has_one :user
end
