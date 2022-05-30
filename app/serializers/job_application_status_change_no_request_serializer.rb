class JobApplicationStatusChangeNoRequestSerializer < ActiveModel::Serializer
  attributes :id, :comment, :created_at, :employer_id, :employer_name, :jobseeker_id

  has_one :interview
  has_one :offer_letter
  has_one :job_application_status

  def employer_name
    User.find_by_id(object.employer_id).try(:full_name)
  end
end
