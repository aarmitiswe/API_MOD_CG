class JobStatusSerializer < ActiveModel::Serializer
  attributes :id, :status, :ar_status

  # def status
  #   serialization_options[:ar] && object.ar_status ? object.ar_status : object.status
  # end
end
