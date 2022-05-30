require 'active_support/concern'

module DeactivateJobseeker
  extend ActiveSupport::Concern

  included do
    def deactive_all_comments
      self.comments.update_all(is_active: true)
    end
    
    def deactivate_all_job_applications_jobseeker
      unsuccess_status_id = JobApplicationStatus.find_by_status(JobApplicationStatus::UNSUCCESS)
      success_status_id = JobApplicationStatus.find_by_status(JobApplicationStatus::SUCCESS)
      self.jobseeker.job_applications.where.not(job_application_status_id: success_status_id).update_all(job_application_status_id: unsuccess_status_id)
    end

    def change_notification_jobseeker
      self.notification.update_columns(blog: 0, poll_question: 0, job: 0, candidate: nil, newsletter: false)
    end

    def deactivate_jobseeker
      deactive_all_comments
      deactivate_all_job_applications_jobseeker
      change_notification_jobseeker
    end
  end
end