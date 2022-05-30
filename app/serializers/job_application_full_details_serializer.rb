class JobApplicationFullDetailsSerializer < ActiveModel::Serializer
  attributes :id, :applied_date

  has_one :job, serializer: JobListSerializer
  has_many :job_application_status_changes
  has_many :notes



  def applied_date
    object.created_at
  end
end