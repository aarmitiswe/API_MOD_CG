class JobseekerHashTagSerializer < ActiveModel::Serializer
  attributes :id
  has_one :hash_tag
end
