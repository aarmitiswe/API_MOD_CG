class HashTag < ActiveRecord::Base
  include Pagination
  has_many :jobseeker_hash_tags
  # has_many :jobseeker_hash_tags, inverse_of: :hash_tag
  # accepts_nested_attributes_for :jobseeker_hash_tags, allow_destroy: true

  validates_presence_of :name
  validates_uniqueness_of :name
end
