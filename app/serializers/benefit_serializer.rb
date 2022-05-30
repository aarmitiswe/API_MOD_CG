class BenefitSerializer < ActiveModel::Serializer
  attributes :id, :name, :icon

  def name
    serialization_options[:ar] && object.ar_name ? object.ar_name : object.name
  end
end
