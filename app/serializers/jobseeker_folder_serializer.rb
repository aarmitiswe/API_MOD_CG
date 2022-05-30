class JobseekerFolderSerializer < ActiveModel::Serializer
  attributes :id
  has_one :jobseeker, serializer: JobseekerListSerializer, root: :jobseeker
end
