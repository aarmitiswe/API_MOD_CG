class CultureSerializer < ActiveModel::Serializer
  attributes :id, :title, :avatar
  has_one :company

  def company
    {id: object.company.try(:id), name: object.company.try(:name)}
  end
end
