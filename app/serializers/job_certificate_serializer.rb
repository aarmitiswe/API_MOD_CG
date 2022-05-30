class JobCertificateSerializer < ActiveModel::Serializer
  attributes :id, :name

  def name
    object.certificate.name
  end

  def id
    object.certificate.id
  end
end
