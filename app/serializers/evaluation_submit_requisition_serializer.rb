class EvaluationSubmitRequisitionSerializer < ActiveModel::Serializer
  attributes :id, :status, :active

  has_one :organization
  has_one :user
end
