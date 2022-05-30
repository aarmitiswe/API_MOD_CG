class EvaluationSubmitRequisition < ActiveRecord::Base
  include SendInvitation

  belongs_to :evaluation_form
  belongs_to :evaluation_submit
  belongs_to :job_application
  belongs_to :organization
  belongs_to :user


  validates :job_application_id, uniqueness: {scope: [:user_id, :evaluation_submit_id]}

  STATUSES = %w(approved rejected sent)

  STATUSES.each do |status_val|
    define_method("is_#{status_val}?") { self.status == status_val }
  end

  APPROVE_STATUS = 'approved'
  APPROVED_STATUS = 'approved'
  REJECT_STATUS = 'rejected'
  SENT_STATUS = 'sent'

  scope :sent, -> { where(status: SENT_STATUS) }
  scope :rejected, -> { where(status: REJECT_STATUS) }
  scope :approved, -> { where(status: APPROVE_STATUS) }
  scope :active, -> { where(active: true) }
  scope :pending, -> { where(active: false) }

  after_commit :check_next_requisition, on: [:update]

  def job
    self.job_application.job
  end

  def grade
    self.job.grade
  end

  def get_next_requisition
    self.evaluation_submit.evaluation_submit_requisitions.sent.first
  end

  def check_next_requisition
    next_requisition = self.get_next_requisition

    if self.is_approved? || self.is_sent?
      if next_requisition.present?
        next_requisition.send_mail "ask_approval"
        next_requisition.update_column(:active, true)
      else
        self.send_mail "full_approval"
      end
    elsif self.is_rejected?
      self.send_mail "reject"
    end
  end

  def get_feedback_template_values
    all_organizations = self.job.get_all_organizations
    template_values = {
        JobTitle: self.job.title,
        JobId: self.job.id,
        JobseekerFullName: self.job_application.jobseeker.full_name,
        JobseekerUserId: self.job_application.jobseeker.user.id,
        recruiter: self.job.user.full_name,
        Recruiter: self.job.user.full_name,
        CreatorName: self.job.user.full_name,
        Approver: self.user.full_name,
        HiringManagerName: self.organization.present? ? self.organization.managers.first.try(:full_name) : "",
        UserName: self.user.full_name,
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
        RequisitionIdNumber: self.job.id,
        RequisitionSubmitter: self.job.user.full_name,
        TypeOfRequisition: self.job.employment_type ? Job::EMPLOYMENT_TYPE_MAIL[self.job.employment_type] : "NA",
        Grade: self.grade.try(:name) || "NA",
        Unit: all_organizations.select{|org| org.organization_type.name == 'Unit'}.first.try(:name) || "-",
        Section: all_organizations.select{|org| org.organization_type.name == 'Section'}.first.try(:name) || "-",
        Department: all_organizations.select{|org| org.organization_type.name == 'Department'}.first.try(:name) || "-",
        GeneralDepartment: all_organizations.select{|org| org.organization_type.name == 'General Department'}.first.try(:name) || "-",
        Deputy: all_organizations.select{|org| org.organization_type.name == 'Deputy'}.first.try(:name) || "-",
        OrgName: self.organization.try(:name) || "HIRING MANAGER" # TODO: Add correct Org
    }
    template_values
  end

  def send_mail action
    template_values = self.get_feedback_template_values

    if self.active == true

      if action == "ask_approval"

        self.send_email "ask_approval_evaluation_form",
                        [{email: self.user.email, name: self.user.full_name}],
                        {
                            message_body: nil,
                            message_subject: "طلب مراجعه استمارة تقييم",
                            template_values: template_values
                        }
        puts action

      elsif action == "full_approval"
        self.job_application.review_evaluation_form

        # template_values[:HiringManagerName] = self.user.full_name
        #
        #
        #
        # receivers = User.recruiters.map{|rec| {email: rec.email, name: rec.full_name}} | [{email: self.job.user.email, name: self.job.user.full_name}]
        #
        # self.send_email "requisition_approval_for_recruiter_evaluation_form",
        #                 receivers,
        #                 {
        #                     message_body: nil,
        #                     message_subject: "تمت الموافقة على استمارة تقييم",
        #                     template_values: template_values
        #                 }
        puts action

      elsif action == "reject"
        template_values = self.get_feedback_template_values
        #TODO: if :recruiter is not used may have to be removed and use only :Recruiter
        template_values[:recruiter] = self.job.user.full_name
        template_values[:Recruiter] = self.job.user.full_name

        self.send_email "requisition_rejection_evaluation_form",
                        [{email: self.job.user.email, name: self.job.user.full_name}],
                        {
                            message_body: nil,
                            message_subject: "تم رفض استمارة تقييم",
                            template_values: template_values
                        }

        self.evaluation_submit.evaluation_submit_requisitions.approved.each_with_index do |req, index|
          puts "#{req.user.email}"
          #TODO: if :recruiter is not used may have to be removed and use only :Recruiter
          template_values[:recruiter] = req.user.full_name
          template_values[:Recruiter] = req.user.full_name

          self.delay(run_at: ((index+1)*10).seconds.from_now).send_email "requisition_rejection_evaluation_form",
                                                                         [{email: req.user.email, name: req.user.full_name}],
                                                                         {
                                                                             message_body: nil,
                                                                             message_subject: "تم رفض استمارة تقييم",
                                                                             template_values: template_values
                                                                         }
        end
        puts action
      end

    end

  end
end
