class PositionMiniSerializer < ActiveModel::Serializer
  attributes :id, :job_title, :ar_job_title, :job_description, :employment_type,
             :military_level, :military_force, :position_status_id, :oracle_id

  has_one :organization, serializer: OrganizationNoAllParentSerializer

end
