class Api::V1::EventVisitorSerializer < ActiveModel::Serializer
  attributes :id, :name, :company, :position, :department, :mobile_phone, :email
end
