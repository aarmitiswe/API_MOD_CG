require "base64"

class Interview < ActiveRecord::Base
  include SendInvitation

  PASSED_INTERVIEW = 'passed'
  FAILED_INTERVIEW = 'failed'

  belongs_to :job_application_status_change
  has_one :job_application, through: :job_application_status_change
  has_one :job, through: :job_application
  has_one :jobseeker, through: :job_application_status_change, class_name: User, foreign_key: 'jobseeker_id'
  has_one :employer, through: :job_application_status_change, class_name: User, foreign_key: 'employer_id'
  # has_one :interviewer, class_name: User, foreign_key: 'interviewer_id', source: :user
  has_many :calls, dependent: :destroy
  has_many :interview_committee_members, dependent: :destroy

  scope :is_selected, -> { where(is_selected: true) }
  scope :selected, -> { where(is_selected: true) }

  #validates_presence_of :interviewer_id
  #validates_inclusion_of :channel, in: %w(Hangout Skype GoMeeting Phone Call Physical)
  #validates_inclusion_of :status, in: %w(invite accept reject)
  #validates_inclusion_of :interviewer_id, in: Proc.new{ |interview| User.find_by_id(interview.interviewer_id).company.user_ids }

  # validates_presence_of :jobseeker_contact, if: lambda { self.status == 'accept' }

  #after_update :reply_to_employer
  after_create :send_mails
  # after_destroy :send_mails_with_interview
  after_save :send_mails_with_interview
  after_commit :send_mails_interview_result, on: :update

  def send_mails
    if self.job_application_status_change.try(:interviews).try(:count) > 1 && (self.job_application_status_change.is_assessment? || self.job_application_status_change.is_securityclearance? || self.job_application_status_change.is_joboffer?)
      self.job_application_status_change.job_application.send_suggested_assessment_interviews
    end
  end


  def send_mails_with_interview
    if (self.is_selected || self.job_application_status_change.try(:interviews).try(:count) == 1) && (self.job_application_status_change.is_assessment? || self.job_application_status_change.is_securityclearance? || self.job_application_status_change.is_joboffer?)
      self.job_application_status_change.job_application.send_selected_interview_assessment
    end
  end

  def send_mails_interview_result
    if !self.interview_status.nil?
      # self.job_application_status_change.job_application.check_and_send_notification
      self.job_application_status_change.job_application.send_selected_interview_assessment
    end
  end

  # Create Bulk of Interviews
  def self.create_bulk job_application_id, user_jobseeker_id, employer_id, appointments, time_zone, comment, duration, interviewer_id, interviewer_designation
    job_application_status_change = JobApplicationStatusChange.new(jobseeker_id: user_jobseeker_id, employer_id: employer_id,
                                                                   job_application_status_id: JobApplicationStatus.find_by_status("Selected").id,
                                                                   job_application_id: job_application_id)

    job_application_status_change.save

    interviews = []
    appointments.each do |appointment|
      interview = Interview.new(appointment: appointment, time_zone: time_zone, comment: comment,
                                duration: duration, interviewer_id: interviewer_id, job_application_status_change_id: job_application_status_change.id,
                                interviewer_designation: interviewer_designation)
      interview.save

      interviews << interview
    end

    interviews
  end

  def company
    self.employer.try(:company) || self.interviewer.try(:company)
  end

  def interviewer
    User.find_by_id(self.interviewer_id)
  end

  def appointment_time_zone
    self.appointment.in_time_zone(self.time_zone)
  end

  def current_jobseeker_company
    self.jobseeker.current_jobseeker_company
  end

  def is_accepted_by_jobseeker?
    self.jobseeker_contact.present? && self.jobseeker_contact != "reject"
  end

  def is_appointment_not_now?
    ((self.appointment.in_time_zone(self.time_zone) - Time.now.in_time_zone(self.time_zone)) / 60.0) > 10.0 ||
        ((Time.now.in_time_zone(self.time_zone) - self.appointment.in_time_zone(self.time_zone)) / 60.0) > (self.duration)
    return false
  end

  def get_reply_template_values
    template_values = {
        URLRoot: Rails.application.secrets[:BACKEND],
        Website: Rails.application.secrets[:FRONTEND],
        CompanyImg: self.job.company.avatar(:original),
        # EmployerFullName: self.employer.full_name,
        EmployerFullName: self.interviewer.full_name,
        CompanyName: self.company.name
        # JobseekerReply: self.is_accepted_by_jobseeker? ? "My Contact: #{self.jobseeker_contact}" : "Sorry, I can't attend the Interview"Interview
    }
    template_values
  end

  def interviewers
    interviewers_users = self.interview_committee_members.map{|member| member.user}
    interviewers_users.fill(nil, interviewers_users.count..4)
    interviewers_users
  end

  def reply_to_employer

    # If interview committee not active
    if !Rails.application.secrets['INTERVIEW_COMMITTEE']
      self.interview_committee_members = [{user: self.interviewer}]
    end

    if self.status == 'accept'

      time_sending_reminder = [self.appointment - 2.hours, Time.now.utc + 5.minutes].max

      diff_minutes = (self.appointment - time_sending_reminder) / 60
      diff_time = diff_minutes <= 0 ? "few minutes" : "#{diff_minutes.round} minutes"
      template_values = self.job_application_status_change.get_feedback_template_values
      template_values[:DiffTime] = diff_time



      self.delay(run_at: time_sending_reminder, queue: 'interview_reminder').send_email "reminder_#{self.channel.downcase}_interview_jobseeker",
                                                           [{email: self.jobseeker.email, name: self.jobseeker.full_name}],
                                                           {
                                                               message_body: nil,
                                                               message_subject: "Reply on Interview for #{self.job.title}",
                                                               template_values: template_values
                                                           }

      # Sending emails to all interviewers
      self.interview_committee_members.each do |sel_interviewer|

        # Sending reminders emails to all interviewers
        self.delay(run_at: time_sending_reminder, queue: 'interview_reminder')
            .send_email "reminder_#{self.channel.downcase}_interview_employer",
                        [{email: sel_interviewer.user.email, name: sel_interviewer.user.full_name}],
                        {
                            message_body: nil,
                            message_subject: "Reply on Interview for #{self.job.title}",
                            template_values: template_values
                        }


       # Sending accepted interview emails to all interviewers
        self.send_email "accept_interview_employer",
                                                      [{email: sel_interviewer.user.email, name: sel_interviewer.user.full_name}],
                                                      {
                                                          message_body: nil,
                                                          message_subject: "Reply on Interview for #{self.job.title}",
                                                          template_values: template_values
                                                      }
      end

    else
      template_values = self.job_application_status_change.get_feedback_template_values

      # Sending reject emails all interviewer

      self.interview_committee_members.each do |sel_interviewer|
        self.delay.send_email "#{self.status}_interview",
                              [{email: sel_interviewer.user.email, name: sel_interviewer.user.full_name}],
                              {
                                  message_body: nil,
                                  message_subject: "Reply on Interview for #{self.job.title}",
                                  template_values: template_values
                              }
      end

    end
  end

  # TODO: Remove it
  def generate_interview_token_old user
    call = Call.find_or_create_by(user_id: user.id, interview_id: self.id,
                                room: "#{self.employer.id}-#{self.jobseeker.id}")

    # Call for one hour
    if call.token.nil?
      token = Vidyo::Token.new(
          key: Rails.application.secrets[:VIDYO_KEY],
          application_id: Rails.application.secrets[:VIDYO_APP_ID],
          user_name: user.is_employer? ? "company-#{user.id}" : "jobseeker-#{user.id}",
          expires_in: (self.duration * 60) + 10
      )

      # enc   = Base64.encode64(token.unserialized)
      # # -> "U2VuZCByZWluZm9yY2VtZW50cw==\n"
      # final_token = Base64.decode64(enc)
      # # -> "Send reinforcements"

      call.update(token: token.serialize)
      # call.update(token: final_token)
    end
    true
  end



  def generate_interview_token user
    call = Call.find_or_create_by(user_id: user.id, interview_id: self.id,
                                  room: "#{self.interviewer.id}-#{self.jobseeker.id}")

    # Call for one hour
    if call.token.nil?
      token = Vidyo::Token.new(
          key: Rails.application.secrets[:VIDYO_KEY],
          application_id: Rails.application.secrets[:VIDYO_APP_ID],
          user_name: user.is_employer? ? "company-#{user.id}" : "jobseeker-#{user.id}",
          expires_in: (self.duration * 60) + 10
      )

      call.update(token: token.serialize)
    end
    true
  end
end
