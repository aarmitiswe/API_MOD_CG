class NewSectionSerializer < ActiveModel::Serializer
  attributes :id, :name, :ar_name
  has_one :department
  has_one :unit
end
