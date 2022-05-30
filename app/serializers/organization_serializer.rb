class OrganizationSerializer < ActiveModel::Serializer
  attributes :id, :name, :parent_organization, :all_parent_orgnizations, :oracle_id

  has_one :organization_type
  has_many :users

  def parent_organization
    {
        id: object.parent_organization_id,
        name: object.parent_organization.try(:name)
    }
  end

  def all_parent_orgnizations
    object.all_parent_orgnizations.map{|org| {id: org.id, name: org.name, type_name: org.organization_type.try(:name), ar_type_name: org.organization_type.try(:ar_name)}}
  end

end
