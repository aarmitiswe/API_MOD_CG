class JobseekerRequiredDocument < ActiveRecord::Base
    include SendInvitation
    include DocumentUpload

    REQUIRED_STATUS = 'required'
    APPROVED_STATUS = 'approved'
    REJECTED_STATUS = 'rejected'
    UPLOADED_STATUS = 'uploaded'

    belongs_to :job_application_status_change

    after_save :update_job_application_status
    after_save :send_notification

    def jobseeker_user
        self.job_application_status_change.jobseeker
    end

    def jobseeker
        self.jobseeker_user.jobseeker
    end

    def job
        self.job_application_status_change.job
    end

    def job_owner
        self.job.user
    end

    def job_application_status
        self.job_application_status_change.job_application_status
    end

    def get_feedback_template_values
        template_values = {
            URLRoot: Rails.application.secrets[:BACKEND],
            Website: Rails.application.secrets[:FRONTEND],
            CompanyImg: self.job.branch && self.job.branch.avatar(:original) ? self.job.branch.avatar(:original) : self.job.company.avatar(:original),
            JobseekerImg: self.jobseeker_user.avatar(:original),
            JobseekerFullName: self.jobseeker.full_name,
            CreateDate: self.created_at.strftime("%d %b, %Y"),
            Status: self.job_application_status.status,
            JobTitle: self.job.title,
            primaryColor: Rails.application.secrets[:ATS_CSS]["colors"]["primary"],
            secondaryColor: Rails.application.secrets[:ATS_CSS]["colors"]["secondary"],
            lightBg: Rails.application.secrets[:ATS_CSS]["colors"]["lightBg"],
            borderColor: Rails.application.secrets[:ATS_CSS]["colors"]["border"],
            WebsiteName: Rails.application.secrets[:ATS_NAME]["website_name"],
            MainLogo: "#{Rails.application.secrets[:BACKEND]}/email_templates/mail-logo.png",
            UserId: self.jobseeker_user.id_6_digits,
            JobOwnerName: self.job.user.full_name,
            JobId: self.job.id,
            JobApplicationId: self.job_application_status_change.job_application_id,
            CompanyName: self.job.company.try(:name),
            ComanyCountry: self.job.company.current_country.try(:name),
            ComanyCity: self.job.company.current_city.name,
            ApplicationId: self.job_application_status_change.job_application_id,
            JobseekerNameUrl: self.jobseeker.full_name.parameterize,
            JobApplicationStatusChangeId: self.job_application_status_change_id,
            EmployerComment: self.employer_comment
        }

        template_values
    end

    def update_job_application_status
        if self.job_application_status_change.jobseeker_required_documents.map(&:status).uniq == [APPROVED_STATUS]
            job_application_status_change = self.job_application_status_change.dup
            job_application_status_change.comment = "UnderOffer"
            job_application_status_change.notify_jobseeker = false
            job_application_status_change.job_application_status_id = JobApplicationStatus.find_by_status("UnderOffer").id
            job_application_status_change.save!
        end
    end

    def send_notification
        # Send To Employer
        if self.status == UPLOADED_STATUS
            self.send_email "ask_employer_to_approve_documents",
                            [{email: self.job_owner.email, name: self.job_owner.full_name}],
                            {
                                message_body: nil,
                                message_subject: "Please Approve Uploaded Documents for #{self.job.title}",
                                template_values: self.get_feedback_template_values
                            }

        elsif self.status == REJECTED_STATUS
            self.send_email "reject_jobseeker_documents",
                            [{email: self.jobseeker_user.email, name: self.jobseeker_user.full_name}],
                            {
                                message_body: nil,
                                message_subject: "Your Documents Approved for #{self.job.title}",
                                template_values: self.get_feedback_template_values
                            }
        end
        # @Todo: According to sajeer this email is not required
        # elsif self.job_application_status_change.jobseeker_required_documents.map(&:status).uniq == [APPROVED_STATUS]
        #     self.send_email "approve_jobseeker_documents",
        #                     [{email: self.jobseeker_user.email, name: self.jobseeker_user.full_name}],
        #                     {
        #                         message_body: nil,
        #                         message_subject: "Your Documents Approved for #{self.job.title}",
        #                         template_values: self.get_feedback_template_values
        #                     }
        #
        # end
    end
end