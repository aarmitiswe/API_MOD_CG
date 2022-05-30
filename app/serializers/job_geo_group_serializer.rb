class JobGeoGroupSerializer < ActiveModel::Serializer
  attributes :id, :name

  def name
    object.geo_group.name
  end

  def id
    object.geo_group.id
  end
end
