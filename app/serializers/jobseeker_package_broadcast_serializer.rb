class JobseekerPackageBroadcastSerializer < ActiveModel::Serializer
  attributes :id
  has_one :package_broadcast
end
