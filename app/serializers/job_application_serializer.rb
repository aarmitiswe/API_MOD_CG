class JobApplicationSerializer < ActiveModel::Serializer
  delegate :current_user, to: :scope

  attributes :id, :jobseeker, :applied_date, :security_clearance_document, :is_security_cleared, :employment_type, :candidate_type,
             :extra_document, :extra_document_title, :terminated_at

  has_one :job, serializer: JobListSerializer
  has_one :jobseeker_resume
  has_one :jobseeker_coverletter
  has_one :job_application_status
  has_many :job_application_status_changes, root: :employer_feedbacks, serializer: JobApplicationStatusChangeSerializer
  has_many :boarding_forms

  def jobseeker
    {id: object.jobseeker.id}
  end

  def applied_date
    object.created_at
  end

  # Return latest job_application_status for Jobseeker
  def job_application_status
    job_application_status = if current_user.is_jobseeker?
                                  object.job_application_status_changes.notify_jobseeker.order(:created_at).last.try(:job_application_status)
                             else
                                  object.job_application_status
                             end
    JobApplicationStatusSerializer.new(job_application_status || JobApplicationStatus.find_by_status("Applied"), root: false).serializable_object(serialization_options)
  end

  # TODO: Refactor it later
  # def employer_feedbacks
  #   job_application_status_changes = if current_user.is_jobseeker?
  #                                      object.job_application_status_changes.notify_jobseeker.order(:created_at)
  #                                    else
  #                                      object.job_application_status_changes.order(:created_at)
  #                                    end
  #
  #   job_application_status_changes.map{|obj| JobApplicationStatusChangeSerializer.new(obj, root: false).serializable_object(serialization_options) }
  # end
end
