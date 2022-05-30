class BlogTagSerializer < ActiveModel::Serializer
  attributes :id, :name

  def id
    object.tag.id
  end

  def name
    object.tag.name
  end
end
