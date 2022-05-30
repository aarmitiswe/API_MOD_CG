class Page < ActiveRecord::Base
  has_many :meta_tags
  has_many :page_images
  has_many :images, through: :page_images
end
