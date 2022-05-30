class CompanyAllSerializer < ActiveModel::Serializer
  attributes :id, :name, :sector_id, :country_id
end
