class OrganizationNoAllParentSerializer < ActiveModel::Serializer
  attributes :id, :name, :parent_organization, :oracle_id

  has_one :organization_type

  def parent_organization
    {
        id: object.parent_organization_id,
        name: object.parent_organization.try(:name)
    }
  end

end
