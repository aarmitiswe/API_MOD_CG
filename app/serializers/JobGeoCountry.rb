class JobGeoCountrySerializer < ActiveModel::Serializer
  attributes :id, :name

  def name
    object.geo_country.name
  end

  def id
    object.geo_country.id
  end
end
