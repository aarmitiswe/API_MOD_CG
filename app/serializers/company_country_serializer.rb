class CompanyCountrySerializer < ActiveModel::Serializer
  attributes :id, :country

  def country
    serialization_options[:ar] && object.country.ar_name ? object.country.ar_name : object.country.name
  end
end
