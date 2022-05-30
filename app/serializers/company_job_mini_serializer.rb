class CompanyJobMiniSerializer < ActiveModel::Serializer
  delegate :current_user, to: :scope

  attributes :id,
             :title

  has_one :job_status

end
