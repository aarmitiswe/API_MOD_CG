class NationalitySerializer < ActiveModel::Serializer
  attributes :id, :name

  def name
    object.nationality
  end
end
