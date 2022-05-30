class UnitSerializer < ActiveModel::Serializer
  attributes :id, :name, :ar_name
  has_one :department
end
