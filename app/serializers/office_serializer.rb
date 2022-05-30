class OfficeSerializer < ActiveModel::Serializer
  attributes :id, :name, :ar_name
  has_one :company
  has_one :country
  has_one :city
end
