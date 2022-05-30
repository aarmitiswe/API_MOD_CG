class JobRequest < ActiveRecord::Base
  include Pagination
  include SendInvitation

  APPROVE_STATUS = 'approved'
  REJECT_STATUS = 'rejected'
  SENT_STATUS = 'sent'


  belongs_to :job
  belongs_to :hiring_manager
  belongs_to :grade
  belongs_to :budgeted_vacancy
  belongs_to :organization
  accepts_nested_attributes_for :job
  scope :active, -> { where('job_requests.deleted IS NULL OR job_requests.deleted = ?', false) }
  scope :count_used_budgeted_vacancies, -> (budgeted_vacancy_id) { where("deleted = ? and budgeted_vacancy_id = ?", false, budgeted_vacancy_id).sum(:total_number_vacancies)
  }
  scope :in_progress_approver_one, -> { where("status_approval_one  = 'sent'") }
  scope :in_progress_approver_two, -> { where("status_approval_one  = 'sent' OR status_approval_two  = 'sent'") }
  scope :in_progress_approver_three, -> { where("status_approval_one  = 'sent' OR status_approval_two  = 'sent' OR status_approval_three  = 'sent'") }
  scope :in_progress_approver_four, -> { where("status_approval_one  = 'sent' OR status_approval_two  = 'sent' OR status_approval_three  = 'sent'  OR status_approval_four  = 'sent'") }
  scope :in_progress_approver_five, -> { where("status_approval_one  = 'sent' OR status_approval_two  = 'sent' OR status_approval_three  = 'sent'  OR status_approval_four  = 'sent'  OR status_approval_five  = 'sent'") }
  scope :not_rejected, -> { where("status_approval_one  != 'rejected' AND status_approval_two  != 'rejected' AND status_approval_three  != 'rejected'  AND status_approval_four  != 'rejected'  AND status_approval_five  != 'rejected'") }
  scope :is_rejected, -> { where("status_approval_one  = 'rejected' OR status_approval_two  = 'rejected' OR status_approval_three  = 'rejected'  OR status_approval_four  = 'rejected'  OR status_approval_five  = 'rejected'") }

  after_save :send_mails_to_approvers

  def get_feedback_template_values

    num_approvers_config = self.hiring_manager.num_approvers

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
        primaryColor: Rails.application.secrets[:ATS_CSS]["colors"]["primary"],
        secondaryColor: Rails.application.secrets[:ATS_CSS]["colors"]["secondary"],
        lightBg: Rails.application.secrets[:ATS_CSS]["colors"]["lightBg"],
        borderColor: Rails.application.secrets[:ATS_CSS]["colors"]["border"],
        WebsiteName: Rails.application.secrets[:ATS_NAME]["website_name"],
        CompanyName: self.job.company.name,
        CompanyImg: self.job.company.avatar(:original),
        CreatorName: self.job.user.first_name,
        CreateDate: self.created_at.strftime("%d %b, %Y"),
        CreatedDate: self.created_at.strftime("%d %b, %Y"),
        ApproverOneName: "#{self.hiring_manager.approver_one.try(:first_name)} #{self.hiring_manager.approver_one.try(:last_name)}",
        ApproverTwoName: "#{self.hiring_manager.approver_two.try(:first_name)} #{self.hiring_manager.approver_two.try(:last_name)}",
        ApproverThreeName:  "#{self.hiring_manager.approver_three.try(:first_name)} #{self.hiring_manager.approver_three.try(:last_name)}",
        ApproverFourName:  "#{self.hiring_manager.approver_four.try(:first_name)} #{self.hiring_manager.approver_four.try(:last_name)}",
        ApproverFiveName:  "#{self.hiring_manager.approver_five.try(:first_name)} #{self.hiring_manager.approver_five.try(:last_name)}",
        ApproverList:  approver_list,
        HiringManagerName:  'Hiring Manager',
        RecruiterName:  'Recruiter',
        TitleJob: self.job.title,
        JobURL: "#{Rails.application.secrets[:FRONTEND]}/employer/requisition/job-details/#{self.id}",
        Subject: "General Subject",
        RejectorName: "General Name",
        ReasonReject: "General Reason"
    }

    template_values
  end

  def send_mails_to_approvers
    if  self.deleted != true
      if self.request_for_approval
        num_approvers_config =  self.hiring_manager.num_approvers
        templates_values = self.get_feedback_template_values
        direct_publish = Rails.application.secrets[:REQUISITION_DIRECT_PUBLISH]

        if self.status_approval_one == SENT_STATUS
          templates_values[:Subject] = "FIRST APPROVAL ON JOB POSTING REQUEST"

          self.send_email "approve_one",
                          [{email: self.hiring_manager.approver_one.email, name: self.hiring_manager.approver_one.full_name}],
                          {message_body: nil, template_values: templates_values}

        elsif self.status_approval_two == SENT_STATUS && self.status_approval_one == APPROVE_STATUS && num_approvers_config >= 2

          templates_values[:Subject] = "SECOND APPROVAL ON JOB POSTING REQUEST"

          self.send_email "approve_two",
                          [{email: self.hiring_manager.approver_two.email, name: self.hiring_manager.approver_two.full_name}],
                          {message_body: nil, template_values: templates_values}

        elsif self.status_approval_three == SENT_STATUS && self.status_approval_one == APPROVE_STATUS && self.status_approval_two == APPROVE_STATUS && num_approvers_config >= 3

          templates_values[:Subject] = "THIRD APPROVAL ON JOB POSTING REQUEST"

          self.send_email "approve_three",
                          [{email: self.hiring_manager.approver_three.email, name: self.hiring_manager.approver_three.full_name}],
                          {message_body: nil, template_values: templates_values}

        elsif self.status_approval_four == SENT_STATUS && self.status_approval_one == APPROVE_STATUS && self.status_approval_two == APPROVE_STATUS && self.status_approval_three == APPROVE_STATUS  && num_approvers_config >= 4

          templates_values[:Subject] = "FORTH APPROVAL ON JOB POSTING REQUEST"

          self.send_email "approve_four",
                          [{email: self.hiring_manager.approver_four.email, name: self.hiring_manager.approver_four.full_name}],
                          {message_body: nil, template_values: templates_values}

        elsif self.status_approval_one == APPROVE_STATUS && (self.status_approval_two == APPROVE_STATUS || num_approvers_config <= 1) &&
            (self.status_approval_three == APPROVE_STATUS  || num_approvers_config <= 2)  && (self.status_approval_four == APPROVE_STATUS  || num_approvers_config <= 3)

          templates_values[:Subject] = "FINAL APPROVAL ON JOB POSTING REQUEST"
          templates_values[:JobURL] = "#{Rails.application.secrets[:FRONTEND]}/employer/requisition/vacancy/#{self.id}"
          self.job.position.lock_position
          # If diect publish no email is sent to the hiring managers
          if !direct_publish
            # Sending final approval to all hiring managers
            self.hiring_manager.hiring_manager_owners.each do |sel_hiring_manager_owner|
              templates_values[:HiringManagerName] = sel_hiring_manager_owner.user.full_name

              if sel_hiring_manager_owner.user.active
                self.delay.send_email "final_approve",
                                      [{email: sel_hiring_manager_owner.user.email, name: sel_hiring_manager_owner.user.full_name}],
                                      {message_body: nil, template_values: templates_values}
              end

            end

            # Sending final approval to all Recruiters
            self.job.company.company_users.each do |sel_user|
              if sel_user.user.active  &&  sel_user.user.is_recruiter?

                templates_values[:RecruiterName] = sel_user.user.full_name
                self.delay.send_email "final_approve_recruiter",
                                      [{email: sel_user.user.email, name: sel_user.user.full_name}],
                                      {message_body: nil, template_values: templates_values}
                # self.job.position.lock_position
              end
            end
          else
            # Sending Publish job email toRecruiters
            self.job.company.company_users.each do |sel_user|
              if sel_user.user.active  &&  sel_user.user.is_recruiter?

                templates_values[:RecruiterName] = sel_user.user.full_name
                self.delay.send_email "publish_job_recruiter",
                                      [{email: sel_user.user.email, name: sel_user.user.full_name}],
                                      {message_body: nil, template_values: templates_values}
              end
            end
          end




        elsif self.status_approval_one == REJECT_STATUS || self.status_approval_two == REJECT_STATUS || self.status_approval_three == REJECT_STATUS

          templates_values[:Subject] = "REJECTION ON JOB POSTING REQUEST"

          templates_values[:RejectorName] = if self.status_approval_one == REJECT_STATUS
                                              self.hiring_manager.approver_one.first_name
                                            elsif self.status_approval_two == REJECT_STATUS
                                              self.hiring_manager.approver_two.first_name
                                            elsif self.status_approval_three == REJECT_STATUS
                                              self.hiring_manager.approver_three.first_name
                                            end

          # TODO: Add `reject_reason_one` & `reject_reason_two` ... in DB later
          templates_values[:ReasonReject] = if self.status_approval_one == REJECT_STATUS
                                              self.rejection_reason_one
                                            elsif self.status_approval_two == REJECT_STATUS
                                              self.rejection_reason_two
                                            elsif self.status_approval_three == REJECT_STATUS
                                              self.rejection_reason_three
                                            end

          # Sending Rejection email to all hiring managers
          self.hiring_manager.hiring_manager_owners.each do |sel_hiring_manager_owner|

            self.delay.send_email "reject_job_request",
                            [{email: sel_hiring_manager_owner.user.email, name: sel_hiring_manager_owner.user.full_name}],
                            {message_body: nil, template_values: templates_values}
          end


        end
      end
    else
      if self.job.deleted != true
        self.job.update(deleted: true)
      end
    end

  end
end
