class UniversitySerializer < ActiveModel::Serializer
  attributes :id, :name

  has_one :country
end