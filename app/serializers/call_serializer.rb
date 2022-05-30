class CallSerializer < ActiveModel::Serializer
  attributes :id, :token, :room

  has_one :user
end
