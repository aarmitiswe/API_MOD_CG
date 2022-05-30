class JobApplicationLogSerializer < ActiveModel::Serializer
  attributes :id, :log_type, :created_at

  has_one :user
  has_one :job_application
end
