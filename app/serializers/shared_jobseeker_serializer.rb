class SharedJobseekerSerializer < ActiveModel::Serializer
  attributes :id
  has_one :sender
  has_one :receiver
  has_one :jobseeker
end
