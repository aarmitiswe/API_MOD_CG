require 'active_support/concern'

module DeactivateEmployer
  extend ActiveSupport::Concern

  included do
    @company_ids = []
    @job_ids = []

    def set_company_ids
      @company_ids = self.company_users.pluck(:company_id)
    end

    def set_job_ids
      @job_ids = Job.where(company_id: @company_ids).pluck(:id)
    end

    def deactivate_all_companies
      self.companies.update_all(active: false)
    end

    def deactivate_all_employers
      employers = User.where(id: CompanyUser.where(company_id: @company_ids).pluck(:user_id))
      employers.update_all(active: false)
    end

    def deactivate_all_jobs
      Job.where(company_id: @company_ids).update_all(active: false)
    end

    def deactivate_all_blogs
      Blog.where(company_user_id: CompanyUser.where(company_id: @company_ids).pluck(:id)).update_all(is_active: false)
    end

    def deactivate_all_job_applications_employer
      unsuccess_status_id = JobApplicationStatus.find_by_status(JobApplicationStatus::UNSUCCESS)
      success_status_id = JobApplicationStatus.find_by_status(JobApplicationStatus::SUCCESS)
      JobApplication.where(job_id: @job_ids).where.not(job_application_status_id: success_status_id).update_all(job_application_status_id: unsuccess_status_id)
    end

    def deactivate_all_poll_questions
      employers = User.where(id: CompanyUser.where(company_id: @company_ids).pluck(:user_id))
      PollQuestion.where(user_id: employers.map(&:id)).update_all(active: false)
    end

    def change_notification_employer
      self.notification.update_columns(blog: 0, poll_question: 0, job: nil, candidate: 0, newsletter: false) if self.notification
    end

    def change_owner
      self.companies.each do |company|
        company_owner_id = company.owner.id
        company_user = CompanyUser.find_by(user_id: self.id, company_id: company.id)
        Job.where(user_id: self.id, company_id: company.id).update_all(user_id: company_owner_id)
        Blog.where(company_user_id: CompanyUser.find_by(user_id: self.id, company_id: company.id).id).update_all(company_user_id: company_user.id) if company_user
        PollQuestion.where(user_id: self.id).update_all(user_id: company_owner_id)
      end
    end

    def are_all_companies_active?
      self.companies.pluck(:active).any?
    end

    def deactivate_employer
      set_company_ids
      set_job_ids
      if self.is_company_owner?
        deactivate_all_companies
        deactivate_all_employers
        deactivate_all_jobs
        deactivate_all_blogs
        deactivate_all_job_applications_employer
        deactivate_all_poll_questions
      elsif self.is_company_admin? || self.is_company_user?
        change_owner
      end

      change_notification_employer
    end

    # The following to active Company Owner Account
    def active_company_owner
      set_company_ids
      set_job_ids
      self.update_column(:active, true)
      activate_all_companies
      activate_all_employers
      activate_all_jobs
      activate_all_blogs
      activate_all_poll_questions
    end

    def activate_all_companies
      self.companies.update_all(active: true)
    end

    def activate_all_employers
      employers = User.where(id: CompanyUser.where(company_id: @company_ids).pluck(:user_id))
      employers.update_all(active: true)
    end

    def activate_all_jobs
      Job.where(company_id: @company_ids).update_all(active: true)
    end

    def activate_all_blogs
      Blog.where(company_user_id: CompanyUser.where(company_id: @company_ids).pluck(:id)).update_all(is_active: true)
    end

    def activate_all_poll_questions
      employers = User.where(id: CompanyUser.where(company_id: @company_ids).pluck(:user_id))
      PollQuestion.where(user_id: employers.map(&:id)).update_all(active: true)
    end
  end
end