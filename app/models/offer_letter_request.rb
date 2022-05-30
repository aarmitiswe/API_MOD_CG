require 'wicked_pdf'
require 'wicked_pdf/pdf_helper'
require 'base64'

class OfferLetterRequest < ActiveRecord::Base
  include Pagination
  include SendInvitation
  APPROVE_STATUS = 'approved'
  REJECT_STATUS = 'rejected'
  SENT_STATUS = 'sent'

  belongs_to :job_application_status_change
  belongs_to :offer_letter
  belongs_to :hiring_manager
  accepts_nested_attributes_for :offer_letter


  scope :in_progress_approver_one, -> { where("status_approval_one  = 'sent'") }
  scope :in_progress_approver_two, -> { where("status_approval_one  = 'sent' OR status_approval_two  = 'sent'") }
  scope :in_progress_approver_three, -> { where("status_approval_one  = 'sent' OR status_approval_two  = 'sent' OR status_approval_three  = 'sent'") }
  scope :in_progress_approver_four, -> { where("status_approval_one  = 'sent' OR status_approval_two  = 'sent' OR status_approval_three  = 'sent'  OR status_approval_four  = 'sent'") }
  scope :in_progress_approver_five, -> { where("status_approval_one  = 'sent' OR status_approval_two  = 'sent' OR status_approval_three  = 'sent'  OR status_approval_four  = 'sent'  OR status_approval_five  = 'sent'") }

  after_save :send_mails_to_approvers

  def jobseeker_user
    self.job_application_status_change.jobseeker
  end

  def jobseeker
    self.jobseeker_user.jobseeker
  end


  def job
    self.job_application.job
  end

  def job_application
    self.job_application_status_change.job_application
  end

  def add_offer_letter_old
    @jobseeker = self.jobseeker
    @offer_letter_request = self
    view = ActionView::Base.new(ActionController::Base.view_paths, {})
    view.extend(ApplicationHelper)
    view.extend(Rails.application.routes.url_helpers)
    pdf = WickedPdf.new.pdf_from_string(
        render_to_string(template: "api/v1/offer_letters/#{@offer_letter_request.offer_letter_type || 'saudi_expat_external_offer'}.html.erb")
    )
    save_path = Rails.root.join('pdfs','filename.pdf')
    document = File.open(save_path, 'wb') do |file|
      file << pdf
    end

    offer_letter = self.offer_letter ? self.offer_letter.update(document: document) : OfferLetter.create(document: document)
    self.update_column(:offer_letter_id, offer_letter.id)
  end

  def add_offer_letter current_user
    return if self.offer_letter_type.blank?
    offer_letters_controller = Api::V1::OfferLettersController.new
    pdf = offer_letters_controller.save_as_pdf self, current_user
    document_pdf_content = Base64.encode64(pdf)

    File.open("offer_letter_#{self.id}.pdf", "wb") do |file|
      file.write(Base64.decode64(document_pdf_content))
    end
    document_pdf = File.new("offer_letter_#{self.id}.pdf")

    offer_letter = if self.offer_letter
                      self.offer_letter.update(job_application_status_change_id: self.job_application_status_change_id, document: document_pdf)
                      self.offer_letter
                   else
                      OfferLetter.create(job_application_status_change_id: self.job_application_status_change_id, document: document_pdf)
                   end
    # offer_letter = self.offer_letter ? self.offer_letter.update(job_application_status_change_id: self.job_application_status_change_id, document: document_pdf) : OfferLetter.create(job_application_status_change_id: self.job_application_status_change_id, document: document_pdf)
    self.update_column(:offer_letter_id, offer_letter.id)
  end

  def get_feedback_template_values

    num_approvers_config = self.job_application_status_change.job_application.job.try(:job_request).try(:hiring_manager).try(:num_approvers)

    approver_list = ""
    approver_matcher= %w(approver_one approver_two approver_three approver_four approver_five)

    (1..num_approvers_config).to_a.each_with_index do |a, a_index|

      approver_list += (a == 1 ) ? "" : (a  == num_approvers_config) ? " and " : ", "
      approver_list += "#{self.hiring_manager.send(approver_matcher[a_index]).try(:first_name)} #{self.hiring_manager.send(approver_matcher[a_index]).try(:last_name)}"
    end

    template_values = {
        URLRoot: Rails.application.secrets[:BACKEND],
        Website: Rails.application.secrets[:FRONTEND],
        MainLogo: "#{Rails.application.secrets[:BACKEND]}/email_templates/mail-logo.png",
        CompanyImg: self.job_application_status_change.job_application.job.company.avatar(:original),
        HiringManagerName: self.job_application_status_change.employer.full_name,
        CreateDate: self.created_at.strftime("%d %b, %Y"),
        JobseekerFullName: self.jobseeker_user.full_name,
        UserId: self.job.user.id,
        JobId: self.job.id,
        OfferReqId: self.id,
        JobTitle: self.job.title,
        JobOwnerName: self.job.user.full_name,
        recruiter: self.job.user.full_name,
        ReplyJobseeker: self.reply_jobseeker,
        JobseekeNameUrl: self.jobseeker_user.full_name.parameterize,
        JobseekerId: self.jobseeker_user.id,
        primaryColor: Rails.application.secrets[:ATS_CSS]["colors"]["primary"],
        secondaryColor: Rails.application.secrets[:ATS_CSS]["colors"]["secondary"],
        lightBg: Rails.application.secrets[:ATS_CSS]["colors"]["lightBg"],
        borderColor: Rails.application.secrets[:ATS_CSS]["colors"]["border"],
        WebsiteName: Rails.application.secrets[:ATS_NAME]["website_name"],
        CompanyName: self.job.company.name,
        CreatorName: self.job.user.first_name,
        CreatedDate: self.created_at.strftime("%d %b, %Y"),
        ApproverOneName: "#{self.hiring_manager.approver_one.try(:first_name)} #{self.hiring_manager.approver_one.try(:last_name)}",
        ApproverTwoName: "#{self.hiring_manager.approver_two.try(:first_name)} #{self.hiring_manager.approver_two.try(:last_name)}",
        ApproverThreeName:  "#{self.hiring_manager.approver_three.try(:first_name)} #{self.hiring_manager.approver_three.try(:last_name)}",
        ApproverFourName:  "#{self.hiring_manager.approver_four.try(:first_name)} #{self.hiring_manager.approver_four.try(:last_name)}",
        ApproverFiveName:  "#{self.hiring_manager.approver_five.try(:first_name)} #{self.hiring_manager.approver_five.try(:last_name)}",
        ApproverList:  approver_list,
        CommentApprover:  '',
        TitleJob: self.job.title,
        JobURL: "#{Rails.application.secrets[:FRONTEND]}/employer/routing-form/#{self.jobseeker_user.id}/job-offer?jobid=#{self.job.id}&jobseekerid=#{self.jobseeker.id}&offerid=#{self.id}&jobrequestid=#{self.job_application_status_change.job_application.job.job_request.id}",
        Subject: "General Subject",
        RejectorName: "General Name",
        ReasonReject: "General Reason"
    }

    template_values
  end

  def send_mails_to_approvers
    if  self.deleted != true
        num_approvers_config = Rails.application.secrets['NUM_OFFER_APPROVERS']
        templates_values = self.get_feedback_template_values

        if self.status_approval_one == SENT_STATUS
          templates_values[:Subject] = "FIRST APPROVAL ON Offer Letter REQUEST"
          self.send_email "accept_offer_approver_one",
                          [{email: self.hiring_manager.approver_one.email, name: self.hiring_manager.approver_one.full_name}],
                          {message_body: nil, template_values: templates_values}

        elsif self.status_approval_two == SENT_STATUS && self.status_approval_one == APPROVE_STATUS && num_approvers_config >= 2
          templates_values[:Subject] = "SECOND APPROVAL ON Offer Letter REQUEST"

          self.send_email "accept_offer_approver_two",
                          [{email: self.hiring_manager.approver_two.email, name: self.hiring_manager.approver_two.full_name}],
                          {message_body: nil, template_values: templates_values}

        elsif self.status_approval_three == SENT_STATUS && self.status_approval_one == APPROVE_STATUS && self.status_approval_two == APPROVE_STATUS && num_approvers_config >= 3
          templates_values[:Subject] = "THIRD APPROVAL ON Offer Letter REQUEST"

          self.send_email "accept_offer_approver_three",
                          [{email: self.hiring_manager.approver_three.email, name: self.hiring_manager.approver_three.full_name}],
                          {message_body: nil, template_values: templates_values}

        elsif self.status_approval_four == SENT_STATUS && self.status_approval_one == APPROVE_STATUS && self.status_approval_two == APPROVE_STATUS && self.status_approval_three== APPROVE_STATUS && num_approvers_config >= 4
          templates_values[:Subject] = "FORTH APPROVAL ON Offer Letter REQUEST"

          self.send_email "accept_offer_approver_four",
                          [{email: self.hiring_manager.approver_four.email, name: self.hiring_manager.approver_four.full_name}],
                          {message_body: nil, template_values: templates_values}


        elsif self.status_approval_one == APPROVE_STATUS && (self.status_approval_two == APPROVE_STATUS || num_approvers_config <= 1) &&
            (self.status_approval_three == APPROVE_STATUS  || num_approvers_config <= 2) && (self.status_approval_four == APPROVE_STATUS  || num_approvers_config <= 3) && self.status_jobseeker.blank?
          templates_values[:Subject] = "FINAL APPROVAL ON Offer Letter REQUEST"

          # All Recruiters will get the FINAL APPROVAL ON Offer Letter REQUEST
          User.active.is_recruiter.each do |sel_user|
            self.send_email "accept_offer_approver_final",
                            [{email: sel_user.email, name: sel_user.full_name}],
                            {message_body: nil, template_values: templates_values}
          end


        elsif self.status_approval_one == APPROVE_STATUS && (self.status_approval_two == APPROVE_STATUS || num_approvers_config <= 1) &&
            (self.status_approval_three == APPROVE_STATUS  || num_approvers_config <= 2) && (self.status_approval_four == APPROVE_STATUS  || num_approvers_config <= 3)  && self.status_jobseeker == SENT_STATUS && !self.offer_letter.nil?
          templates_values[:Subject] = "SEND Offer Letter REQUEST"

          self.send_email "send_offer_jobseeker",
                          [{email: self.jobseeker_user.email, name: self.jobseeker_user.full_name}],
                          {message_body: nil, template_values: templates_values}

        elsif self.status_approval_one == APPROVE_STATUS && (self.status_approval_two == APPROVE_STATUS || num_approvers_config <= 1) &&
            (self.status_approval_three == APPROVE_STATUS  || num_approvers_config <= 2) && (self.status_approval_four == APPROVE_STATUS  || num_approvers_config <= 3)  && self.status_jobseeker == REJECT_STATUS && !self.offer_letter.nil?
          templates_values[:Subject] = "Reject Offer Letter REQUEST"

          self.send_email "reject_offer_jobseeker",
                          [{email: self.job_application_status_change.employer.email, name: self.job_application_status_change.employer.full_name}],
                          {message_body: nil, template_values: templates_values}

        elsif self.status_approval_one == APPROVE_STATUS && (self.status_approval_two == APPROVE_STATUS || num_approvers_config <= 1) &&
            (self.status_approval_three == APPROVE_STATUS  || num_approvers_config <= 2) && (self.status_approval_four == APPROVE_STATUS  || num_approvers_config <= 3)  && self.status_jobseeker == APPROVE_STATUS && !self.offer_letter.nil?
          templates_values[:Subject] = "Accept Offer Letter REQUEST"

          # All Recruiters will get the accept offer request_for_approval
          User.active.is_recruiter.each do |sel_user|
            self.send_email "accept_offer_jobseeker",
                            [{email: sel_user.email, name: sel_user.full_name}],
                            {message_body: nil, template_values: templates_values}
          end


          self.move_to_accept_offer

        elsif self.status_approval_one == REJECT_STATUS || self.status_approval_two == REJECT_STATUS || self.status_approval_three == REJECT_STATUS || self.status_approval_four == REJECT_STATUS

          templates_values[:Subject] = "REJECTION ON Offer Letter REQUEST"

          templates_values[:RejectorName] = if self.status_approval_one == REJECT_STATUS
                                              self.hiring_manager.approver_one.first_name
                                            elsif self.status_approval_two == REJECT_STATUS
                                              self.hiring_manager.approver_two.first_name
                                            elsif self.status_approval_three == REJECT_STATUS
                                              self.hiring_manager.approver_three.first_name
                                            end

          # TODO: Add `reject_reason_one` & `reject_reason_two` ... in DB later
          templates_values[:ReasonReject] = if self.status_approval_one == REJECT_STATUS
                                              self.comment_approval_one
                                            elsif self.status_approval_two == REJECT_STATUS
                                              self.comment_approval_two
                                            elsif self.status_approval_three == REJECT_STATUS
                                              self.comment_approval_three
                                            end

          self.send_email "reject_offer_approvers",
                          [{email: self.job_application_status_change.employer.email, name: self.job_application_status_change.employer.full_name}],
                          {message_body: nil, template_values: templates_values}

        end
    else
      if self.job.deleted != true
        self.job.update(deleted: true)
      end
    end
  end

  def move_to_accept_offer
    job_application_status_change = self.job_application_status_change.dup
    job_application_status_change.comment = "AcceptOffer"
    job_application_status_change.job_application_status_id = JobApplicationStatus.find_by_status("AcceptOffer").id
    job_application_status_change.notify_jobseeker = true
    job_application_status_change.save!
  end
end
