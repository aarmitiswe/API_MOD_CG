class JobApplicationStatusSerializer < ActiveModel::Serializer
  attributes :id, :status, :en_status, :ar_status

  def status
    serialization_options[:ar] && object.ar_status ? object.ar_status : object.status
  end

  def en_status
    object.status
  end
end
