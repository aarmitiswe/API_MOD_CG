class JobHistory::JobHistorySerializer < ActiveModel::Serializer
  attributes :id, :job_action_type, :record_data, :created_at

  has_one :user, serializer: JobHistory::UserSerializer
  has_one :job, serializer: JobHistory::JobSerializer

  def attributes(*args)
    hash = super
    hash[:jobseeker_name] = jobseeker_name if delete_job_application_action?
    hash
  end

  def delete_job_application_action?
    object.job_action_type === 'delete_job_application' && !object.record_data.nil? && !object.record_data["job_application_id"].nil?
  end

  def jobseeker_name
    job_application = JobApplication.find(object.record_data["job_application_id"])
    user = job_application.jobseeker.user

    "#{user.first_name} #{user.last_name}"
  end
end