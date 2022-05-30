class OfferRequisition < ActiveRecord::Base
  include SendInvitation

  belongs_to :job_application
  belongs_to :user
  belongs_to :offer_analysis
  belongs_to :salary_analysis

  has_one :job, through: :job_application
  has_one :jobseeker, through: :job_application

  REQUISITION_STATUS = %w(sent approved rejected)

  REQUISITION_STATUS.each { |status_val| define_method("is_#{status_val}?") { self.status == status_val } }
  REQUISITION_STATUS.each { |status_val|
    scope status_val.downcase, -> { where(status: status_val) }
  }

  after_commit :go_next_step_offer_cycle, on: :update
  after_commit :send_mail_notification

  def job_application_status_change
    self.job_application.job_application_status_changes.job_offer.order(:created_at).last
  end

  def jobseeker_user
    self.job_application_status_change.jobseeker
  end

  def level
    OfferApprover.where(user_id: self.user_id).last.level
  end

  def go_next_step_offer_cycle
    if is_approved?

      next_user =  OfferApprover.is_old_offer.find_by_level(self.level + 1).try(:user)  if self.job_application_status_change.use_old_offer_approvers?
      next_user =  OfferApprover.is_new_offer.find_by_level(self.level + 1).try(:user)  if !self.job_application_status_change.use_old_offer_approvers?
      if next_user.present?
        OfferRequisition.create(user_id: next_user.id, job_application_id: self.job_application_id, status: 'sent',
          salary_analysis_id: self.salary_analysis_id, offer_analysis_id: self.offer_analysis_id)
      else
        self.job_application_status_change.update(offer_requisition_status: 'approved')
        OfferLetter.create(job_application_status_change_id: self.job_application_status_change.id)
      end
    elsif self.is_rejected?
      self.job_application_status_change.update(offer_requisition_status: 'rejected')
    end
  end

  def get_feedback_template_values
    template_values = {
        JobTitle: self.job.title,
        recruiter: self.job.user.full_name,
        Recruiter: self.job.user.full_name,
        CreatorName: self.job.user.full_name,
        Approver: self.user.full_name,
        UserName: self.user.full_name,
        RejectionReason: self.comment,
        CompanyName: self.job.company.name,
        ArCompanyName: self.job.company.name,
        primaryColor: Rails.application.secrets[:ATS_CSS]["colors"]["primary"],
        secondaryColor: Rails.application.secrets[:ATS_CSS]["colors"]["secondary"],
        lightBg: Rails.application.secrets[:ATS_CSS]["colors"]["lightBg"],
        borderColor: Rails.application.secrets[:ATS_CSS]["colors"]["border"],
        WebsiteName: Rails.application.secrets[:ATS_NAME]["website_name"],
        MainLogo: "#{Rails.application.secrets[:BACKEND]}/email_templates/mail-logo.png",
        CompanyImg: "#{Rails.application.secrets[:BACKEND]}/email_templates/mail-logo.png",
        URLRoot: Rails.application.secrets[:BACKEND],
        Website: Rails.application.secrets[:FRONTEND],
        RecruitmentManager: OfferApprover.find_by_position("Hiring Manager").try(:user).try(:full_name),
        GeneralManagerHR: OfferApprover.find_by_position("General HR Manager").try(:user).try(:full_name),
        ChiefPersonnel: OfferApprover.find_by_position("Chief of Staff Minister of Defense").try(:user).try(:full_name),
        SourcingTeamManager: OfferApprover.where(level: 1).last.try(:user).try(:full_name),
        RecruitmentManagerNew: OfferApprover.where(level: 2).last.try(:user).try(:full_name),
        HrManager: OfferApprover.where(level: 3).last.try(:user).try(:full_name),
        ExecutiveOffice: OfferApprover.where(level: 4).last.try(:user).try(:full_name),
        JobSeekerFullName: self.jobseeker.full_name,
        RequisitionIdNumber: self.job.id,
        HiringManagerName: self.job.user.try(:full_name) || "NA",
        RecruiterName: self.job_application_status_change.employer.try(:full_name),
        TypeOfRequisition: self.job.employment_type ? Job::EMPLOYMENT_TYPE_MAIL[self.job.employment_type] : "NA",
        Grade: self.job.position.grade.try(:name),
        JobSeekerId: self.jobseeker_user.try(:id),
        JobseekerUserId: self.jobseeker_user.try(:id),
        JobseekerURLName: self.jobseeker.full_name.gsub!(" ", "-"),
        JobId: self.job.id,
        MobileNumber: self.jobseeker.mobile_phone,
        EmailId: self.jobseeker.email,
        NationalIdNumber: self.jobseeker.id_number
    }
    template_values
  end

  def send_mail_notification
    template_values = self.get_feedback_template_values
    template_values[:RecruitmentManager]
    template_values[:GeneralManagerHR]
    if self.is_sent?
      send_email_approvers(template_values) if self.job_application_status_change.use_old_offer_approvers?
      send_email_new_approvers(template_values) unless self.job_application_status_change.use_old_offer_approvers?
    elsif self.is_rejected?
      receivers = User.recruiters_for_job(self.job).map{|rec| {email: rec.email, name: rec.full_name}}

      receivers.each_with_index do |receiver, index|
        template_values[:RecruiterName] = receiver[:name]

        self.delay(run_at: ((index+1)*10).seconds.from_now).send_email "rejected_offer_letter",
                                                                       [receiver],
                                                                       {
                                                                           message_body: nil,
                                                                           message_subject: "تم رفض تحليل الراتب للمرشح",
                                                                           template_values: template_values
                                                                       }

        sleep 1
      end

    elsif self.is_approved?

      if self.salary_analysis.all_offer_approved?
        receivers = User.recruiters_for_job(self.job).map{|rec| {email: rec.email, name: rec.full_name}}

        receivers.each_with_index do |receiver, index|
          template_values[:RecruiterName] = receiver[:name]

          self.delay(run_at: ((index+1)*10).seconds.from_now).send_email "approved_offer_letter",
                                                                         [receiver],
                                                                         {
                                                                             message_body: nil,
                                                                             message_subject: "تم اعتماد تحليل الراتب للمرشح",
                                                                             template_values: template_values
                                                                         }

          sleep 1
        end

        self.delay.send_email "approved_offer_letter",
                             [{email: User.recruitment_manager.first.email, name: User.recruitment_manager.first.full_name}],
                             {
                                 message_body: nil,
                                 message_subject: "تم اعتماد تحليل الراتب للمرشح",
                                 template_values: template_values
                             }
      end

    end
  end


  def send_email_new_approvers(template_values)
    if OfferApprover.where(user_id:self.user_id).last.position  == 'Sourcing Team Manager'
      self.send_email "send_offer_request_level_new_1",
                      [{ email: self.user.email, name: self.user.full_name }],
                      {
                        message_body: nil,
                        message_subject: "طلب اعتماد تحليل الراتب للمرشح",
                        template_values: template_values }
    elsif OfferApprover.where(user_id:self.user_id).last.position  == 'Recruitment Manager'
      self.send_email "send_offer_request_level_new_2",
                      [{ email: self.user.email, name: self.user.full_name }],
                      {
                        message_body: nil,
                        message_subject: "طلب اعتماد تحليل الراتب للمرشح",
                        template_values: template_values }
    elsif OfferApprover.where(user_id:self.user_id).last.position  == 'Hiring Manager'
      self.send_email "send_offer_request_level_new_3",
                      [{ email: self.user.email, name: self.user.full_name }],
                      {
                        message_body: nil,
                        message_subject: "طلب اعتماد تحليل الراتب للمرشح",
                        template_values: template_values }
    elsif OfferApprover.where(user_id:self.user_id).last.position == 'Executive Office'
      self.send_email "send_offer_request_level_new_4",
                      [{ email: self.user.email, name: self.user.full_name }],
                      {
                        message_body: nil,
                        message_subject: "طلب اعتماد تحليل الراتب للمرشح",
                        template_values: template_values }

    end
  end



  def send_email_approvers(template_values)
    if OfferApprover.find_by_user_id(self.user_id).position == 'Hiring Manager'
      self.send_email "send_offer_request_level_1",
                      [{ email: self.user.email, name: self.user.full_name }],
                      {
                        message_body: nil,
                        message_subject: "طلب اعتماد تحليل الراتب للمرشح",
                        template_values: template_values }
    elsif OfferApprover.find_by_user_id(self.user_id).position == 'General HR Manager'
      self.send_email "send_offer_request_level_2",
                      [{ email: self.user.email, name: self.user.full_name }],
                      {
                        message_body: nil,
                        message_subject: "طلب اعتماد تحليل الراتب للمرشح",
                        template_values: template_values }
    elsif OfferApprover.find_by_user_id(self.user_id).position == 'Chief of Staff Minister of Defense'
      self.send_email "send_offer_request_level_3",
                      [{ email: self.user.email, name: self.user.full_name }],
                      {
                        message_body: nil,
                        message_subject: "طلب اعتماد تحليل الراتب للمرشح",
                        template_values: template_values }
    elsif OfferApprover.find_by_user_id(self.user_id).position == 'Assistant Minister of Defense'
      self.send_email "send_offer_request_level_4",
                      [{ email: self.user.email, name: self.user.full_name }],
                      {
                        message_body: nil,
                        message_subject: "طلب اعتماد تحليل الراتب للمرشح",
                        template_values: template_values }

    end
  end
end
