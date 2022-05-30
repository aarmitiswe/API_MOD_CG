class FeaturedCompanySerializer < ActiveModel::Serializer
  attributes :id
  has_one :company

  def company
    object.company.as_json(only: [:id, :name]).as_json.merge(avatar: object.company.avatar(:original))
  end
end
