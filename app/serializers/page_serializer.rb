class PageSerializer < ActiveModel::Serializer
  attributes :id, :name, :url, :title, :role

  has_many :meta_tags
  has_many :page_images, root: :images
end
