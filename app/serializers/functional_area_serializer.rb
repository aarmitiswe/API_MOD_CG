class FunctionalAreaSerializer < ActiveModel::Serializer
  attributes :id, :name

  def name
    serialization_options[:ar] && object.ar_area ? object.ar_area : object.area
  end
end
