class JobseekerTagSerializer < ActiveModel::Serializer
  attributes :id, :name, :tag_type

  def name
    object.tag.name
  end

  def tag_type
    object.tag.tag_type
  end

  def id
    object.tag.id
  end
end