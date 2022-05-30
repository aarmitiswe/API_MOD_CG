class PositionSerializer < ActiveModel::Serializer
  attributes :id, :job_title, :ar_job_title, :job_description, :employment_type,
             :military_level, :military_force, :position_status_id, :oracle_id

  has_one :job_type
  has_one :grade
  has_one :job_status
  has_one :job_experience_level
  has_one :organization
  has_one :position_status
end
