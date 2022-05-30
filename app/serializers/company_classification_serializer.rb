class CompanyClassificationSerializer < ActiveModel::Serializer
  attributes :id, :name

  def name
    serialization_options[:ar] && object.ar_name ? object.ar_name : object.name
  end
end
