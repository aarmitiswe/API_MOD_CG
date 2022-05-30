class CompanyMemberSerializer < ActiveModel::Serializer
  attributes :id, :name, :position, :facebook_url, :twitter_url, :linkedin_url, :google_plus_url, :avatar, :video
  has_one :company

  def company
    {id: object.company.id, name: object.company.name}
  end
end
