class JobseekerCompanyBroadcastSerializer < ActiveModel::Serializer
  attributes :id, :status
  has_one :company
end
