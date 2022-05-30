class PageImageSerializer < ActiveModel::Serializer
  attributes :id, :alt, :name, :url

  def name
    object.image.name
  end

  def url
    object.image.url
  end
end
