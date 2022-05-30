class Requisition < ActiveRecord::Base
  include SendInvitation
  include Pagination

  belongs_to :user
  belongs_to :job
  belongs_to :organization

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
  scope :not_rejected, -> { where.not(status: REJECT_STATUS) }
  scope :active, -> { where(active: true) }
  scope :pending, -> { where(active: false) }
  scope :not_deleted, -> { where(is_deleted: false) }

  after_commit :check_next_requisition, on: [:update]
  after_commit :update_job_requisition_status

  def self.update_active
    Requisition.approved.where.not(active: true).update_all(active: true)
    Requisition.rejected.where.not(active: true).update_all(active: true)
  end

  def self.set_approved_at
    Requisition.approved.where(approved_at: nil).each do |req|
      req.update_column(:approved_at, req.updated_at || req.created_at)
    end
  end

  def update_job_requisition_status
    return if self.nil? || self.job.nil?
    if self.job.is_approved?
      self.job.update_column(:requisition_status, APPROVE_STATUS)
      self.job.update_column(:approved_at, DateTime.now)
      self.job.update_column(:job_status_id, JobStatus.find_by(status: 'Open').try(:id))
    elsif self.job.is_rejected?
      self.job.update_column(:requisition_status, REJECT_STATUS)
    elsif self.job.is_sent?
      self.job.update_column(:requisition_status, SENT_STATUS)
    end
  end

  def check_next_requisition
    next_requisition = self.job.requisitions_active.sent.first
    if self.is_approved? || self.is_sent?
      if next_requisition.present?
        # self.send_mail "notify_approval"
        next_requisition.send_mail "ask_approval"
        next_requisition.update_column(:active, true)
      else
        # job = self.job
        # job.job_status_id = 2
        # job.save
        self.send_mail "full_approval"
      end
    elsif self.is_rejected?
      self.send_mail "reject"
    end
  end


  # TODO: Send mail to the user
  def self.send_mail_to_next_user job
    next_requisition = job.requisitions_active.sent.first
    if next_requisition.present?
      next_requisition.update_column(:active, true)
      next_requisition.send_mail "ask_approval"
    end
    next_requisition
  end

  def grade
    self.job.position.try(:grade)
  end

  def get_feedback_template_values
    all_organizations = self.job.get_all_organizations
    template_values = {
        JobTitle: self.job.title,
        recruiter: self.job.user.full_name,
        Recruiter: self.job.user.full_name,
        CreatorName: self.job.user.full_name,
        Approver: self.user.full_name,
        HiringManagerName: self.organization.present? ? self.organization.managers.first.try(:full_name) : "",
        UserName: self.user.full_name,
        RejectionReason: self.reason,
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

  # TODO: Add sending mails
  def send_mail action
    template_values = self.get_feedback_template_values

    if action == "notify_approval"
      self.send_email "requisition_approval",
                      [{email: self.user.email, name: self.user.full_name}],
                      {
                          message_body: nil,
                          message_subject: "",
                          template_values: template_values
                      }
      puts action
    elsif action == "ask_approval"

      self.send_email "ask_approval",
                      [{email: self.user.email, name: self.user.full_name}, {email: self.job.user.email, name: self.job.user.full_name}],
                      {
                          message_body: nil,
                          message_subject: "طلب موافقة على نشر وظيفة جديدة",
                          template_values: template_values
                      }
      puts action

    elsif action == "full_approval"
      self.job.position.lock_position
      # self.send_email "requisition_approval",
      #                 [{email: self.user.email, name: self.user.full_name}],
      #                 {
      #                     message_body: nil,
      #                     message_subject: "تمت الموافقة على طلب وظيفة",
      #                     template_values: self.get_feedback_template_values
      #                 }
      template_values[:HiringManagerName] = self.user.full_name



      receivers = User.recruiters_for_job(self.job).map{|rec| {email: rec.email, name: rec.full_name}} | [{email: self.job.user.email, name: self.job.user.full_name}]

      self.send_email "requisition_approval_for_recruiter",
                      receivers,
                      {
                          message_body: nil,
                          message_subject: "تمت الموافقة على طلب وظيفة – الرجاء إضافة مرشحين",
                          template_values: template_values
                      }

      # Send Final Approved Email to the hiring manager of the organization
      receivers = [{email: self.job.hiring_manager.email, name: self.job.hiring_manager.full_name}]
      self.send_email "requisition_full_approved_inform_hiring_manager",
                      receivers,
                      {
                        message_body: nil,
                        message_subject: "الموافقة على طلب الوظيفة",
                        template_values: template_values
                      }


      # rec_receivers = User.recruiters.map{|rec| {email: rec.email, name: rec.full_name}}

      # User.recruiters.each_with_index do |rec, index|
      #
      #
      #   self.delay(run_at: ((index+1)*10).seconds.from_now).send_email "requisition_approval_for_recruiter",
      #                   [{email: rec.email, name: rec.full_name}],
      #                   {
      #                       message_body: nil,
      #                       message_subject: "تمت الموافقة على طلب وظيفة – الرجاء إضافة مرشحين",
      #                       template_values: template_values
      #                   }
      #
      #   sleep 1
      # end

      # User.recruiters.each_with_index do |rec, index|
      #   puts "#{rec.email}"
      #   template_values[:HiringManagerName] = rec.full_name
      #
      #   self.delay(run_at: ((index+1)*10).seconds.from_now).send_email "requisition_approval_for_creator",
      #                   [{email: rec.email, name: rec.full_name}],
      #                   {
      #                       message_body: nil,
      #                       message_subject: "تمت الموافقة على طلب وظيفة – الرجاء إضافة مرشحين",
      #                       template_values: template_values
      #                   }
      # end
      puts action

    elsif action == "reject"
      template_values = self.get_feedback_template_values
      #TODO: if :recruiter is not used may have to be removed and use only :Recruiter
      template_values[:recruiter] = self.job.user.full_name
      template_values[:Recruiter] = self.job.user.full_name

      # Email send to the job Owner
      self.send_email "requisition_rejection",
                      [{email: self.job.user.email, name: self.job.user.full_name}],
                      {
                          message_body: nil,
                          message_subject: "تم رفض طلب وظيفة",
                          template_values: template_values
                      }

      # Email send to the Approves that have approved or pending to approve
      self.job.requisitions_active.not_rejected.each_with_index do |req, index|
            puts "#{req.user.email}"
            #TODO: if :recruiter is not used may have to be removed and use only :Recruiter
            template_values[:recruiter] = req.user.full_name
            template_values[:Recruiter] = req.user.full_name

            self.delay(run_at: ((index+1)*10).seconds.from_now).send_email "requisition_rejection",
                            [{email: req.user.email, name: req.user.full_name}],
                            {
                                message_body: nil,
                                message_subject: "تم رفض طلب وظيفة",
                                template_values: template_values
                            }

      end
      puts action
    end
  end
end


# 1) Create set of requisitions for first organization (The level at which the vacancy was submitted) and set them all to sent and send emails for each manager
# 2) When one manager approves, repeat step one for parent level (order + 1). Until it reaches the Agency Manager.
# * If requisition created at Section or Unit => First approvers are Department Managers
# * If requition created at Department Level =>  First approvers are General Department Managers
# * If requition created at General Department Level =>  First approvers are Agency Managers
