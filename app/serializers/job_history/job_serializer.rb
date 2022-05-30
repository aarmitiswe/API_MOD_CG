class JobHistory::JobSerializer < ActiveModel::Serializer
  delegate :current_user, to: :scope

  attributes :id,
             :title,
             :created_at,
             :deleted,
             :active

  has_one :job_status
end