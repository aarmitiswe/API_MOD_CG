class PositionCvSourceSerializer < ActiveModel::Serializer
    attributes :id, :name, :ar_name
  
    # def status
    #   serialization_options[:ar] && object.ar_status ? object.ar_status : object.status
    # end
end