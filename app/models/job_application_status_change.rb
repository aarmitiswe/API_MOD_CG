class JobApplicationStatusChange < ActiveRecord::Base
  include SendInvitation
  include ActiveModel::Validations

    ASSESSOR_GRADES = (1..4).to_a.map{|num| Grade.where("name = (?) or name = (?)", "Level #{num}", "Grade #{num}").pluck(:name)}.flatten
    ENG_PERSON_GRADES = Grade.where("name != (?) and name != (?) and name != (?) and name != (?)", "Level 0", "Grade 0", "Level 1", "Grade 1").pluck(:name).flatten
    ON_BOARDING_STATUSES = ['beginning', 'pre_joining', 'joined']

  belongs_to :job_application
  belongs_to :job_application_status
  belongs_to :jobseeker, class_name: User, foreign_key: 'jobseeker_id'
  belongs_to :employer, class_name: User, foreign_key: 'employer_id'
  has_one :job, through: :job_application
  has_many :interviews, dependent: :destroy
  has_one :candidate_information_document, dependent: :destroy
  has_many :assessments, dependent: :destroy
  has_many :offer_requisitions, through: :job_application
  has_many :boarding_forms, through: :job_application

  has_many :offer_analyses, -> { order(:level) }, through: :job_application
  has_many :salary_analyses, -> { order(:level) }, through: :job_application

  accepts_nested_attributes_for :interviews, allow_destroy: true

  accepts_nested_attributes_for :candidate_information_document
  accepts_nested_attributes_for :assessments
  has_many :offer_letters, -> { order(created_at: :desc) }, dependent: :destroy
  accepts_nested_attributes_for :offer_letters, allow_destroy: true
  has_one :offer_letter_request, dependent: :destroy

  has_many :jobseeker_required_documents, dependent: :destroy

  # validates_uniqueness_of :job_application_status_id, :scope => [:job_application_id, :jobseeker_id]
  # This validation to prevent Go Back for Status. (e.g: Success can't change again to reviewed)
  # validate :check_status
  validates_presence_of :jobseeker_id, :employer_id

  # before_create :force_set_notify_jobseeker
  after_create :update_job_application
  # after_create :send_feedback_to_job_owner
  after_create :initiate_assessment_job_offer
  before_save :set_on_boarding_status
  after_save :move_to_complete
  after_save :push_to_oracle
  # after_save :watheq_check_notification
  after_save :joined_notification
  after_save :pre_join_notification
  after_save :beginning_notification
  after_save :upload_onboard_document_notification
  after_save :check_if_hired_move_rest_unsuccessful

  scope :notify_jobseeker, -> { where(notify_jobseeker: true) }

  scope :reviewed, -> { where(job_application_status_id: JobApplicationStatus.find_by_status(JobApplicationStatus::KEYWORDS["Reviewed"]).try(:id)) }
  scope :shortlisted, -> { where(job_application_status_id: JobApplicationStatus.find_by_status(JobApplicationStatus::KEYWORDS["Shortlisted"]).try(:id)) }
  scope :interviewed, -> { where(job_application_status_id: JobApplicationStatus.find_by_status(JobApplicationStatus::KEYWORDS["Interview"]).try(:id)) }
  scope :successful, -> { where(job_application_status_id: JobApplicationStatus.find_by_status(JobApplicationStatus::KEYWORDS["Successful"]).try(:id)) }
  scope :unsuccessful, -> { where(job_application_status_id: JobApplicationStatus.find_by_status(JobApplicationStatus::KEYWORDS["Unsuccessful"]).try(:id)) }
  scope :selected, -> { where(job_application_status_id: JobApplicationStatus.find_by_status(JobApplicationStatus::KEYWORDS["Selected"]).try(:id)) }
  scope :shared, -> { where(job_application_status_id: JobApplicationStatus.find_by_status(JobApplicationStatus::KEYWORDS["Shared"]).try(:id)) }
  scope :pass_interview, -> { where(job_application_status_id: JobApplicationStatus.find_by_status(JobApplicationStatus::KEYWORDS["PassInterview"]).try(:id)) }
  scope :security_clearance, -> { where(job_application_status_id: JobApplicationStatus.find_by_status(JobApplicationStatus::KEYWORDS["SecurityClearance"]).try(:id)) }
  scope :under_offer, -> { where(job_application_status_id: JobApplicationStatus.find_by_status(JobApplicationStatus::KEYWORDS["UnderOffer"]).try(:id)) }
  scope :assessment, -> { where(job_application_status_id: JobApplicationStatus.find_by_status(JobApplicationStatus::KEYWORDS["Assessment"]).try(:id)) }
  scope :job_offer, -> { where(job_application_status_id: JobApplicationStatus.find_by_status(JobApplicationStatus::KEYWORDS["JobOffer"]).try(:id)) }
  scope :onboarding, -> { where(job_application_status_id: JobApplicationStatus.find_by_status(JobApplicationStatus::KEYWORDS["OnBoarding"]).try(:id)) }
  scope :on_boarding, -> { where(job_application_status_id: JobApplicationStatus.find_by_status(JobApplicationStatus::KEYWORDS["OnBoarding"]).try(:id)) }
  scope :accept_offer, -> { where(job_application_status_id: JobApplicationStatus.find_by_status(JobApplicationStatus::KEYWORDS["AcceptOffer"]).try(:id)) }
  scope :applied, -> { where(job_application_status_id: JobApplicationStatus.find_by_status(JobApplicationStatus::KEYWORDS["Applied"]).try(:id)) }
  scope :unreviewed, -> { where(job_application_status_id: JobApplicationStatus.find_by_status(JobApplicationStatus::KEYWORDS["Applied"]).try(:id)) }
  scope :in_progress, -> { where.not(job_application_status_id: JobApplicationStatus.where(status: [JobApplicationStatus::KEYWORDS["Successful"], JobApplicationStatus::KEYWORDS["Unsuccessful"]]).pluck(:id)) }
  # scope :applied, -> { where(job_application_id: JobApplicationStatus.find_by_status("Applied").id) }

  def self.update_nil_jobseeker
    JobApplicationStatusChange.where(jobseeker_id: nil).each{|j| j.update(jobseeker_id: j.job_application.jobseeker.user_id)}
  end

  # JobApplicationStatus.all.map{ |job_application_status| job_application_status.status.downcase.to_sym }.each do |scope_name|
  #   scope scope_name, -> { where(job_application_status_id: JobApplicationStatus.find_by_status(scope_name.to_s.humanize).id) }
  # end

  # JobApplicationStatus::KEYWORDS.keys.map{ |job_application_status_value| job_application_status_value.downcase.to_sym }.each do |scope_name|
  #   scope scope_name, -> { where(job_application_status_id: JobApplicationStatus.find_by_status(scope_name.to_s.humanize).id) }
  # end

  # JobApplicationStatus.all.each do |job_application_status|
  #   define_method("is_#{job_application_status.status.downcase}?") { self.job_application_status.status == job_application_status.status }
  # end
  JobApplicationStatus::KEYWORDS.keys.each do |job_application_status_value|
    define_method("is_#{job_application_status_value.downcase}?") { self.job_application_status.status == job_application_status_value }
  end

  def is_successful?
    ["Hired", "Successful", "Completed"].include? self.job_application_status.status
  end

  def check_if_hired_move_rest_unsuccessful
    if  self.is_successful?
      self.job.job_applications
          .where(job_application_status_id: JobApplicationStatus
                                              .where.not(status: ["Hired", "Successful", "Completed", "Unsuccessful"])
                                              .pluck(:id))
          .where.not(jobseeker_id: self.jobseeker.jobseeker.id)
          .each do |sel_job_app|
            sel_job_app.job_application_status_changes.create({job_application_status_id:JobApplicationStatus.find_by_status('Unsuccessful').id,
                                                               employer_id: self.employer_id,
                                                               jobseeker_id: sel_job_app.jobseeker.user.id,
                                                               comment: "Auto move to unsuccessful due to some other candidate moved to successful",
                                                              })
          end
    end
  end

  def upload_onboard_document_notification
    template_values = self.get_feedback_template_values

    if self.on_boarding_status == 'pre_joining'

      receivers = User.recruiters_for_job(self.job).map{|u| {email: u.email, name: u.full_name}}

      self.send_email "upload_onboard_document",receivers, {
          message_body: nil,
          message_subject: " برجاء رفع ملفات الموظف ",
          template_values: template_values
      }
    end

  end

  def beginning_notification
    template_values = self.get_feedback_template_values

    receivers = User.recruiters_for_job(self.job).map{|u| {email: u.email, name: u.full_name}}
    if self.on_boarding_status == 'beginning'
      self.send_email "reminder_uploading_documents",receivers, {
          message_body: nil,
          message_subject: " طلب تزويد الوثائق المطلوبة للتوظيف لوظيفة ",
          template_values: template_values
      }
    end
  end

  def can_send_prejoin?
    self.on_boarding_status == 'pre_joining' && self.joining_date <= (Date.today + 2.weeks)
  end


  def use_old_offer_approvers?
    (self.created_at < Date.parse('14 Mar, 2022').beginning_of_day)
  end

  def pre_join_notification
    template_values = self.get_feedback_template_values

    receivers = Rails.application.secrets['PRE_JOINED_USERS']

    if self.can_send_prejoin?
      receivers.each do |receive|

        template_values[:EmployeeNameWithPosition] = "#{receive[:name]} - #{receive[:position]}"

        self.send_email "notify_joining_date_pre_joining",[receive], {
            message_body: nil,
            message_subject: " الموظف سوف يباشر علي وظيفة ",
            template_values: template_values
        }
      end
    end
  end

  def pre_join_notification_old
    template_values = self.get_feedback_template_values

    receivers = Rails.application.secrets['PRE_JOINED_USERS']

    if self.on_boarding_status == 'pre_joining'
      if !self.watheeq
        # users = User.where(role_id: Role.find_by_name('On-Boarding Support Management System Representative').id)
        #
        # receivers = users.map{|u| {email: u.email, name: u.full_name}}

        self.send_email "notify_joining_date",receivers, {
            message_body: nil,
            message_subject: " إعلام بتاريخ مباشرة الموظف ",
            template_values: template_values
        }

      end


      if !self.performance_evaluation
        # users = User.where(role_id: Role.find_by_name('On-Boarding Performance Evaluation Representative').id)
        #
        # receivers = users.map{|u| {email: u.email, name: u.full_name}}

        self.send_email "notify_joining_date",receivers, {
            message_body: nil,
            message_subject: " إعلام بتاريخ مباشرة الموظف ",
            template_values: template_values
        }

      end


      if !self.on_boarding_session
        # users = User.where(role_id: Role.find_by_name('On-Boarding MOD Session Representative').id)
        #
        # receivers = users.map{|u| {email: u.email, name: u.full_name}}

        self.send_email "notify_joining_date",receivers, {
            message_body: nil,
            message_subject: " إعلام بتاريخ مباشرة الموظف ",
            template_values: template_values
        }

      end
    end
  end

  def watheq_send
    template_values = self.get_feedback_template_values

    self.send_email "final_notification",
                    [{email: User.support_manager.email, name: User.support_manager.full_name}],
                    {
                        message_body: nil,
                        message_subject: " تمت مباشرة الموظف ",
                        template_values: template_values
                    }
  end

  def performance_send
    template_values = self.get_feedback_template_values

    self.send_email "final_notification",
                    [{email: User.performance_evaluation.email, name: User.performance_evaluation.full_name}],
                    {
                        message_body: nil,
                        message_subject: " تمت مباشرة الموظف ",
                        template_values: template_values
                    }
  end

  def session_send
    template_values = self.get_feedback_template_values

    self.send_email "final_notification",
                    [{email: User.session_representative.email, name: User.session_representative.full_name}],
                    {
                        message_body: nil,
                        message_subject: " تمت مباشرة الموظف ",
                        template_values: template_values
                    }
  end

  def joined_notification

    if self.on_boarding_status == 'joined'
      template_values = self.get_feedback_template_values

      receivers = Rails.application.secrets['JOINED_USERS']
      template_values['RecruiterName'] = User.find_by_email(receivers.try(:last).try(:first).try(:last)).try(:full_name)
      self.send_email "final_notification",
                      receivers,
                      {
                          message_body: nil,
                          message_subject: " تمت مباشرة الموظف ",
                          template_values: template_values
                      }

    end
  end

  def watheq_check_notification
    if self.on_boarding_status == 'joined'
      if !self.watheeq
        self.watheq_send
        sleep 1
      end

      if !self.performance_evaluation
        self.performance_send
        sleep 1
      end

      if !self.on_boarding_session
        self.session_send
        sleep 1
      end
    end
  end

  # def watheq_check_notification
  #   # return if !self.watheeq || !self.performance_evaluation || !self.on_boarding_session
  #   if self.on_boarding_status == 'joined' && (!self.watheeq && !self.performance_evaluation && !self.on_boarding_session)
  #     template_values = self.get_feedback_template_values
  #
  #     self.send_email "final_notification",
  #                           [{email: User.support_manager.email, name: User.support_manager.full_name},
  #                            {email: User.performance_evaluation.email, name: User.performance_evaluation.full_name},
  #                            {email: User.session_representative.email, name: User.session_representative.full_name}],
  #                           {
  #                               message_body: nil,
  #                               message_subject: " تمت مباشرة الموظف ",
  #                               template_values: template_values
  #                           }
  #   end

  # end

  def move_to_complete
    # if self.watheeq && self.performance_evaluation && self.on_boarding_session
    #   JobApplicationStatusChange.create(job_application_id: self.job_application_id,
    #     job_application_status_id: JobApplicationStatus.find_by_status('Completed').try(:id),
    #     employer_id: self.employer_id, jobseeker_id: self.jobseeker_id)
    # end
    if self.job_application_status_id == JobApplicationStatus.find_by_status('OnBoarding').id &&
      self.boarding_forms.present? &&
      self.boarding_forms.last.support_management_checked_at.present? &&
      self.boarding_forms.last.it_management_checked_at.present? &&
      self.boarding_forms.last.business_service_management_checked_at.present? &&
      self.boarding_forms.last.security_management_checked_at.present?
      # self.job.position.lock_position
      JobApplicationStatusChange.create(job_application_id: self.job_application_id,
                                        job_application_status_id: JobApplicationStatus.find_by_status('Completed').try(:id),
                                        employer_id: self.employer_id, jobseeker_id: self.jobseeker_id)
    end

  end

  def position
    self.job.position
  end

  def get_oracle_body
    jobseeker_obj = self.oracle_object
    position_obj = {
      "P_POSITION_ID" => self.position.try(:oracle_id),
      # "P_GRADE" => self.position.try(:grade).try(:name)
      "P_GRADE" => ''
    }

    input_obj = {
      "InputParameters" => jobseeker_obj.merge(position_obj)
    }

    input_obj
  end


  def oracle_object
    {
      "P_FIRST_NAME" => self.jobseeker.jobseeker.first_name,
      "P_FATHER_NAME" => self.job_application.offer_letters.try(:last).try(:candidate_second_name) || "NA",
      "P_GRANDFATHER_NAME" => self.job_application.offer_letters.try(:last).try(:candidate_third_name) || "NA",
      "P_LAST_NAME" => self.jobseeker.jobseeker.last_name,
      "P_DATE_OF_BIRTH" => self.job_application.offer_letters.try(:last).try(:candidate_dob).try(:strftime, "%d/%m/%Y") || "NA",
      "P_EMAIL_ADDRESS" => self.jobseeker.jobseeker.email,
      "P_NATIONAL_IDENTIFIER" => self.jobseeker.jobseeker.id_number,
      "P_SEX" => self.job_application.offer_letters.try(:last).try(:candidate_gender)  || "NA",
      "P_TOWN_OF_BIRTH" => self.job_application.offer_letters.try(:last).try(:candidate_birth_city) || "NA",
      "P_COUNTRY_OF_BIRTH" => self.job_application.offer_letters.try(:last).try(:candidate_birth_country) || "NA",
      "P_NATIONALITY" => self.job_application.offer_letters.try(:last).try(:candidate_nationality)  || "NA",
      "P_RELIGION" => self.job_application.offer_letters.try(:last).try(:candidate_religion)  || "NA",
      # "P_EFFECTIVE_START_DATE" => self.job_application.offer_letters.try(:last).try(:joining_date).try(:strftime, "%d/%m/%Y") || "NA"
       "P_EFFECTIVE_START_DATE" => Date.today.try(:strftime, "%d/%m/%Y")
    }
  end

  def push_to_oracle
    if self.on_boarding_status == 'beginning'
      url = "#{Rails.application.secrets[:ORACLE_URL]}/webservices/rest/CreateApplicant/xxmod_create_applicant/"
      uri = URI.parse(url)
      request_body = self.get_oracle_body

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = false
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      request = Net::HTTP::Post.new(uri)
      request.basic_auth(Rails.application.secrets[:ORACLE_USERNAME], Rails.application.secrets[:ORACLE_PASSWORD])
      request["Content-Type"] = 'application/json'
      request.body = request_body.to_json
      puts "BODY: "
      puts request.body
      response = http.request(request)
      puts "RESPONSE: "
      puts response

      res_body = JSON.parse(response.body)
      puts "JSON RESPONSE: "
      puts res_body

      open_mode = "a+"
      File.open("#{Rails.root}/log/xxmod_create_applicant_#{Date.today}.txt", open_mode) do |f|
        f.write("+++++++++++++++++++++++++++++++++++++++++++++++++++++++")
        f.write("\n")
        f.write(url)
        f.write("\n")
        f.write(request.body)
        f.write("\n")
        f.write(res_body)
        f.write("\n")
        f.write("+++++++++++++++++++++++++++++++++++++++++++++++++++++++")
        f.write("\n")

        f.close
      end

      if res_body.present? && res_body["OutputParameters"].present? && res_body["OutputParameters"]["O_STATUS_MESSAGE"] == "SUCCESS"
        oracle_id = res_body["OutputParameters"]["O_APPLICANT_NUMBER"].to_i
        self.jobseeker.jobseeker.update(oracle_id: oracle_id)
        self.jobseeker.update(oracle_id: oracle_id)
      end
    end
  end

  def joining_date
    self.job_application.offer_letters.last.try(:joining_date) || self.offer_letters.last.try(:joining_date) || self.boarding_forms.last.try(:expected_joining_date) || (Date.today + 1.month)
  end

  def get_feedback_template_values
    template_values = {
        URLRoot: Rails.application.secrets[:BACKEND],
        EmployeeNameWithPosition: 'الموظف',
        Website: Rails.application.secrets[:FRONTEND],
        CompanyImg: self.job.branch && self.job.branch.avatar(:original) ? self.job.branch.avatar(:original) : self.job.company.avatar(:original),
        JobseekerImg: self.jobseeker.avatar(:original),
        JobseekeNameUrl: self.jobseeker.full_name.parameterize,
        JobseekerId: self.jobseeker_id,
        JobseekerUserId: self.jobseeker_id,
        JobseekerURLName: self.jobseeker.full_name.gsub!(" ", "-"),
        JobseekerFullName: self.jobseeker.full_name,
        CompanyName: self.job.company.name,
        EmployerComment: self.comment,
        CreateDate: self.created_at.strftime("%d %b, %Y"),
        HijriCreateDate: self.created_at.try(:to_date).try(:to_hijri).try(:strftime, '%d %B, %Y'),
        Status: self.job_application_status.status,
        JobTitle: self.job.title,
        Interviewee: self.try(:interview).try(:interviewee) || self.try(:interview).try(:interviewer).try(:full_name),
        InterviewChannel: (self.try(:interview).try(:channel) == 'Physical') ? 'Face2face Interview' :'Video Interview' ,
        interviewerDesignation: self.try(:interview).try(:interviewer_designation),
        AppointmentDate: (self.try(:interview).try(:appointment_time_zone)).try(:strftime, "%d %b, %Y"),
        HijriAppointmentDate: (self.try(:interview).try(:appointment_time_zone)).try(:to_date).try(:to_hijri).try(:strftime, '%d %B, %Y'),
        AppointmentTime: self.try(:interview).try(:appointment_time_zone).try(:strftime, "%I:%M"),
        Duration: self.try(:interview).try(:duration),
        TimeZone: (self.interviews.last.try(:appointment_time_zone).try(:strftime, "%p") == 'AM')? 'صباحا - (بالتوقيت المحلي) آسيا': 'م - (بالتوقيت المحلي) آسيا',
        primaryColor: Rails.application.secrets[:ATS_CSS]["colors"]["primary"],
        secondaryColor: Rails.application.secrets[:ATS_CSS]["colors"]["secondary"],
        lightBg: Rails.application.secrets[:ATS_CSS]["colors"]["lightBg"],
        borderColor: Rails.application.secrets[:ATS_CSS]["colors"]["border"],
        WebsiteName: Rails.application.secrets[:ATS_NAME]["website_name"],
        MainLogo: "#{Rails.application.secrets[:BACKEND]}/email_templates/mail-logo.png",
        UserId: self.jobseeker.id_6_digits,
        JobOwnerName: self.jobseeker.full_name,
        JobId: self.job.id,
        JobApplicationId: self.job_application_id,
        JobApplicationStatusChangeId: self.id,
        HiringManagerName: self.job.user.full_name,
        Recruiter: self.employer.full_name,
        JobSeekerFullName: self.jobseeker.full_name,
        OnboardingManager: User.onboarding_manager.first.try(:full_name),
        JoiningDate: self.job_application.offer_letters.last.try(:joining_date) || self.offer_letters.last.try(:joining_date) || self.boarding_forms.last.try(:expected_joining_date) || "NA",
        HijriJoiningDate: self.job_application.offer_letters.last.try(:joining_date).try(:to_date).try(:to_hijri).try(:strftime, '%d %B, %Y') || self.offer_letters.last.try(:joining_date).try(:to_date).try(:to_hijri).try(:strftime, '%d %B, %Y') || self.boarding_forms.last.try(:expected_joining_date).try(:to_date).try(:to_hijri).try(:strftime, '%d %B, %Y') || "NA",
        RecruitmentManager: User.recruitment_manager.first.try(:full_name),
        Grade: self.job.try(:position).grade.try(:name),
        RecruiterName: 'وزارة الدفاع,',
        TypeOfRequisition: self.job.employment_type ? Job::EMPLOYMENT_TYPE_MAIL[self.job.employment_type] : "NA",
        JobSeekerId: self.jobseeker_id,
        EmailId: self.jobseeker.email,
        RequisitionIdNumber: self.job.id,
        MobileNumber: self.jobseeker.jobseeker.mobile_phone
    }
    if self.is_interview?

      template_values.merge!({
          CompanyName: self.job.company.try(:name),
          ComanyCountry: self.job.company.current_country.try(:name),
          ComanyCity: self.job.company.current_city.try(:name),
          ChannelName: self.interviews.last.try(:channel),
          ChannelImg: "#{self.interviews.last.try(:channel).try(:downcase)}.png",
          EmployerContact: self.interviews.last.try(:contact),
          AppointmentDate: (self.interviews.last.try(:appointment_time_zone)).try(:strftime, "%d %b, %Y"),
          HijriAppointmentDate: (self.interviews.last.try(:appointment_time_zone)).try(:to_date).try(:to_hijri).try(:strftime, '%d %B, %Y'),
          AppointmentTime: self.interviews.last.try(:appointment_time_zone).try(:strftime, "%I:%M"),
          TimeZone: (self.interviews.last.try(:appointment_time_zone).try(:strftime, "%p") == 'AM')? 'صباحا': 'مساء',
          Interviewee: self.interviews.last.try(:interviewee) || self.interviews.last.try(:interviewer).try(:full_name),
          interviewerDesignation: self.interviews.last.try(:interviewer_designation),
          ApplicationId: self.job_application_id,
          Duration: self.interviews.last.try(:duration),
          InterviewId: self.interviews.last.try(:id),
          JobseekerReply: self.interviews.last.try(:jobseeker_reply),
          JobId: self.job.id,
          JobTitle: self.job.title,
          Address: self.interviews.last.try(:comment),
          GoogleMapUrl: "https://maps.google.com/?q=#{self.interviews.last.try(:comment)}"
      })
    end

    if self.is_successful? || !self.job_application.offer_letters.blank?
      template_values.merge!({
                                 OfferLetter: self.job_application.offer_letters.last.try(:document).try(:url) || Rails.application.secrets[:FRONTEND]
                             })
    end
    template_values
  end

  # def send_feedback_to_job_owner
  #   if self.job_application_status.status == "Shared"
  #     self.send_email "upload_candidate_by_hiring_manager",
  #                     [{email: self.job.user.email, name: self.job.user.full_name}],
  #                     {
  #                         message_body: nil,
  #                         message_subject: "تم ترشيح بعض المرشحين لوظيفة",
  #                         template_values: self.get_feedback_template_values
  #                     }
  #   elsif self.job_application_status.status == "Interview"
  #     self.send_email "suggest_interviews",
  #                     [{email: self.job.user.email, name: self.job.user.full_name}],
  #                     {
  #                         message_body: nil,
  #                         message_subject: "موافقة على طلب توظيف – استعراض مواعيد المقابلة",
  #                         template_values: self.get_feedback_template_values
  #                     }
  #   end
  #
  # end


  def initiate_assessment_job_offer
    if self.is_securityclearance?

      if self.job_application.job_application_status_changes.job_offer.count == 0
        # Creating Job Offer
        applicationStatus_obj = self.dup
        applicationStatus_obj.job_application_status_id = JobApplicationStatus.find_by_status("JobOffer").id
        applicationStatus_obj.comment = "Initiate Job Offer"
        applicationStatus_obj.is_waiting = true
        applicationStatus_obj.save
      end

      if self.job_application.job_application_status_changes.assessment.count == 0
        # Creating Assessment
        applicationStatus_obj = self.dup
        applicationStatus_obj.job_application_status_id = JobApplicationStatus.find_by_status("Assessment").id
        applicationStatus_obj.comment = "Initiate Assessment"
        applicationStatus_obj.is_waiting = true
        assessment_list = []
        # Has Assessor Assessment
        if ASSESSOR_GRADES.include? applicationStatus_obj.job.position.grade.name
          assessment_list.push({assessment_type: Assessment::ASSESSOR_TYPE})
        end
        # Has English & Personality Assessment
        if ENG_PERSON_GRADES.include? applicationStatus_obj.job.position.grade.name
          assessment_list.push({assessment_type: Assessment::ENGLISH_TYPE})
          assessment_list.push({assessment_type: Assessment::PERSONALITY_TYPE})
        end
        # Has QEC Assessment
        if self.job_application.employment_type == 'internal'
          assessment_list.push({assessment_type: Assessment::QEC_TYPE})
        end
        applicationStatus_obj.save

        applicationStatus_obj.assessments.create(assessment_list)
      end

      self.job_application.update_column(:job_application_status_id, JobApplicationStatus.find_by_status("SecurityClearance").id)

    end

  end

  def set_on_boarding_status
    if self.is_onboarding?
      self.on_boarding_status ||= 'beginning'
    end
  end

  # TODO: Remove this one!
  def send_feedback
      template_name = self.is_interview? ? "#{self.interview.channel} #{self.job_application_status.status}" : self.job_application_status.status
      # This condition to avoid



      if self.job_application_status.status == "Selected"
        self.send_email "ask_jobseeker_for_documents",
                        [{email: self.jobseeker.email, name: self.jobseeker.full_name}],
                        {
                            message_body: nil,
                            message_subject: "Please Upload Required Documents for #{self.job.title}",
                            template_values: self.get_feedback_template_values
                        }
      elsif self.job_application_status.status == "UnderOffer"
        # Nothing

      elsif self.job_application_status.status == "AcceptOffer"
      #   Nothing
      elsif self.notify_jobseeker?
        if self.job_application.job.title == "graduate_program" && self.job_application_status.status == "Unsuccessful"
          custom_reject_email
        else

          # No email to be sent for Successful/Hired
          if ["Hired","Successful"].exclude?(self.job_application_status.status)
            self.send_email template_name,
                            [{email: self.jobseeker.email, name: self.jobseeker.full_name}],
                            {
                                message_body: nil,
                                message_subject: "Feedback on #{self.job.title}",
                                template_values: self.get_feedback_template_values
                            }
          end
        end
      end
  end

  def update_job_application
    self.job_application.update(job_application_status_id: self.job_application_status_id) if self.job_application.job_application_status_id != self.job_application_status_id && !self.is_waiting
    self.job_application.update(shared_with_hiring_manager: true) if  self.job_application_status_id == JobApplicationStatus.find_by_status('Shared').id

    # TODO: Check this one
    # if self.is_securityclearance?
    #   if self.job_application.job_application_status_changes.job_offer.blank?
    #
    #     new_job_offer = self.dup
    #     new_job_offer.job_application_status_id = JobApplicationStatus.find_by_status('JobOffer').id
    #     new_job_offer.save
    #   end
    #
    #   if self.job_application.job_application_status_changes.assessment.blank?
    #     new_assessment = self.dup
    #     new_assessment.job_application_status_id = JobApplicationStatus.find_by_status('Assessment').id
    #     new_assessment.save
    #   end
    # end
  end

  def force_set_notify_jobseeker
    self.notify_jobseeker = true if self.is_applied? || self.is_interview?
  end

  def check_status
    latest_order = JobApplicationStatusChange.where(job_application_id: self.job_application_id, jobseeker_id: self.jobseeker_id).map(&:job_application_status).map(&:order).max

    if !latest_order.nil? && latest_order > self.job_application_status.order
      errors.add(:base, "Can't return to previous status")
    end
  end

  private

  def custom_reject_email
    template_values = {
        primaryColor: Rails.application.secrets[:ATS_CSS]["colors"]["primary"],
        secondaryColor: Rails.application.secrets[:ATS_CSS]["colors"]["secondary"],
        lightBg: Rails.application.secrets[:ATS_CSS]["colors"]["lightBg"],
        borderColor: Rails.application.secrets[:ATS_CSS]["colors"]["border"],
        WebsiteName: Rails.application.secrets[:ATS_NAME]["website_name"],
        URLRoot: Rails.application.secrets[:BACKEND],
        Website: Rails.application.secrets[:FRONTEND],
        MainLogo: "#{Rails.application.secrets[:BACKEND]}/email_templates/mail-logo.png",
        JobseekerFullName: self.jobseeker.full_name,
        CompanyName: Rails.application.secrets[:ATS_NAME]["business_name"],
        CreateDate: self.created_at.strftime("%d %b, %Y"),
        HijriCreateDate: self.created_at.try(:to_date).try(:to_hijri).try(:strftime, '%d %B, %Y'),
        UserId: self.jobseeker.id_6_digits
    }

    self.send_email "reject_in_gp",
                    [{email: self.jobseeker.email, name: self.jobseeker.full_name}],
                    {
                        message_body: nil,
                        template_values: template_values
                    }
  end
end
