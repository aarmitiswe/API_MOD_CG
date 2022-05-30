class RequisitionSerializer < ActiveModel::Serializer
  attributes :id, :status, :reason, :approved_at, :organization
  has_one :user
  has_one :job

  def organization
    org = {
        id: nil,
        name: "Manpower Planning"
    }
    if object.organization_id.present?
      org = {
          id: object.organization_id,
          name: object.organization.try(:name)
      }
    end
    org
  end
end
