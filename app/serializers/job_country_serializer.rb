class JobCountrySerializer < ActiveModel::Serializer
  attributes :id, :name

  def name
    serialization_options[:ar] && object.country.ar_name ? object.country.ar_name : object.country.name
  end

  def id
    object.country.id
  end
end
