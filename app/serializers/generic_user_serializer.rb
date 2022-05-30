class GenericUserSerializer < ActiveModel::Serializer
  has_one :country
  has_one :city
  has_one :state
end
