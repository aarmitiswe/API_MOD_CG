class OfferLetter < ActiveRecord::Base
  include DocumentUpload
  include SendInvitation

  belongs_to :job_application_status_change
  has_one :offer_letter_request, dependent: :destroy

  # after_save :send_notification_stc
  after_save :reply_by_jobseeker

  JOBSEEKER_STATUS = %w(approved rejected negotiate)

  JOBSEEKER_STATUS.each { |status_val|
    scope "#{status_val.downcase}_by_jobseeker", -> { where(jobseeker_status: status_val) }
  }

  def job
    self.job_application_status_change.job
  end

  def jobseeker
    self.job_application_status_change.jobseeker.jobseeker
  end

  def reply_by_jobseeker
    template_values = self.get_feedback_template_values

    if self.jobseeker_status == 'rejected'
      receivers = User.recruiters_for_job(self.job).map{|rec| {email: rec.email, name: rec.full_name}}

      receivers.each_with_index do |receiver, index|
        template_values[:RecruiterName] = receiver[:name]

        self.delay(run_at: ((index+1)*10).seconds.from_now).send_email "reject_offer_request",
                                                                       [{email: receiver[:email], name: receiver[:name]}],
                                                                       {
                                                                           message_body: nil,
                                                                           message_subject: "تم رفض العرض الوظيفي من قبل المرشح",
                                                                           template_values: template_values
                                                                       }

        sleep 1
      end
      self.delay.send_email "reject_offer_request",
                           [{email: User.recruitment_manager.first.email, name: User.recruitment_manager.first.full_name}],
                           {
                               message_body: nil,
                               message_subject: "تم رفض العرض الوظيفي من قبل المرشح",
                               template_values: template_values
                           }
    elsif self.jobseeker_status == 'negotiate'
      receivers = User.recruiters_for_job(self.job).map{|rec| {email: rec.email, name: rec.full_name}}

      receivers.each_with_index do |receiver, index|
        template_values[:RecruiterName] = receiver[:name]

        self.delay(run_at: ((index+1)*10).seconds.from_now).send_email "negotiate_offer_request",
                                                                       [{email: receiver[:email], name: receiver[:name]}],
                                                                       {
                                                                           message_body: nil,
                                                                           message_subject: " المفاوضة على العرض الوظيفي مع المرشح",
                                                                           template_values: template_values
                                                                       }

        sleep 1
      end
      self.delay.send_email "negotiate_offer_request",
                           [{email: User.recruitment_manager.first.email, name: User.recruitment_manager.first.full_name}],
                           {
                               message_body: nil,
                               message_subject: " المفاوضة على العرض الوظيفي مع المرشح",
                               template_values: template_values
                           }

    elsif self.jobseeker_status == 'approved'
      self.send_notification_stc
    end
  end

  def self.get_offer_letter_status_count status_name
    OfferLetter.where(jobseeker_status: status_name).count
  end
  
  def get_feedback_template_values
    last_change = self.job_application_status_change
    template_values = {
        JobTitle: self.job.title,
        JobId: self.job.id,
        HiringManagerName: self.job.user.full_name,
        primaryColor: Rails.application.secrets[:ATS_CSS]["colors"]["primary"],
        secondaryColor: Rails.application.secrets[:ATS_CSS]["colors"]["secondary"],
        lightBg: Rails.application.secrets[:ATS_CSS]["colors"]["lightBg"],
        borderColor: Rails.application.secrets[:ATS_CSS]["colors"]["border"],
        WebsiteName: Rails.application.secrets[:ATS_NAME]["website_name"],
        MainLogo: "#{Rails.application.secrets[:BACKEND]}/email_templates/mail-logo.png",
        CompanyImg: "#{Rails.application.secrets[:BACKEND]}/email_templates/mail-logo.png",
        URLRoot: Rails.application.secrets[:BACKEND],
        Website: Rails.application.secrets[:FRONTEND],
        Recruiter: last_change.present? ? last_change.employer.full_name : "NA",
        JobseekerFullName: self.jobseeker.full_name,
        JobseekerUserId: self.jobseeker.user.id,
        JobseekerURLName: self.jobseeker.full_name.gsub!(" ", "-"),
        RequisitionIdNumber: self.job.id,
        TypeOfRequisition: self.job.employment_type ? Job::EMPLOYMENT_TYPE_MAIL[self.job.employment_type] : "NA",
        Grade: self.job.position.grade.try(:name),
        JobSeekerId: self.jobseeker.id,
        JobSeekerFullName: self.jobseeker.full_name,
        MobileNumber: self.jobseeker.mobile_phone,
        EmailId: self.jobseeker.email,
        NationalIdNumber: self.jobseeker.id_number,
        RecruiterName: self.job_application_status_change.employer.try(:full_name)
    }
    template_values
  end

  def send_notification_stc
    template_values = self.get_feedback_template_values

      # receivers = User.onboarding_team.map{|rec| {email: rec.email, name: rec.full_name}}
      receivers = User.onboarding_manager.map{|rec| {email: rec.email, name: rec.full_name}} |
          User.recruiters_for_job(self.job).map{|rec| {email: rec.email, name: rec.full_name}} |
          User.recruitment_manager.map{|rec| {email: rec.email, name: rec.full_name}}

      receivers.each_with_index do |receiver, index|
        template_values[:OnBoardingTeam] = receiver[:name]

        self.delay(run_at: ((index+1)*10).seconds.from_now).send_email "prepare_stc_contract",
                                                                       [receiver],
                                                                       {
                                                                           message_body: nil,
                                                                           message_subject: "طلب إعداد عقد التوظيف من قبل (STCS)",
                                                                           template_values: template_values
                                                                       }

        sleep 1
      end
    # if self.shared_to_stc_at_changed?
    # #   No THING
    # elsif self.received_from_stc_at_changed?
    # #   NO THING
    # elsif self.sent_to_candidate_at_changed?
    # #   NO THING
    # end
  end
end
