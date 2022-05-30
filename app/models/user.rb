require 'net/smtp'

class User < ActiveRecord::Base
  include Pagination
  include SendInvitation
  include VideoUpload
  # Handle it as special case for UI
  self.per_page = 10
  include DeactivateEmployer
  include DeactivateJobseeker

  TEMP_EMAIL_PREFIX = 'change@me'
  TEMP_EMAIL_REGEX = /\Achange@me/
  AGE_RANGES = [
      {age_from: 18, age_to: 25},
      {age_from: 26, age_to: 30},
      {age_from: 31, age_to: 35},
      {age_from: 36, age_to: 40},
      {age_from: 41, age_to: 45},
      {age_from: 46, age_to: 50},
      {age_from: 51, age_to: 55},
      {age_from: 56, age_to: 60},
      {age_from: 61, age_to: 100}
  ]

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  # TODO: Confirmable when sign up Or After create new user (active) send to confirm (redirect to reset password)
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :confirmable, :authentication_keys => [ :email ]

  belongs_to :country
  belongs_to :city
  belongs_to :state
  belongs_to :section
  belongs_to :new_section
  belongs_to :department
  belongs_to :office
  belongs_to :unit
  belongs_to :grade
  belongs_to :role
  has_one :user_invitation, dependent: :destroy
  has_many :company_users, dependent: :destroy
  has_many :companies, through: :company_users, dependent: :destroy
  has_one :jobseeker, dependent: :destroy
  has_one :offer_analysis, dependent: :destroy
  accepts_nested_attributes_for :jobseeker
  has_many :jobs, dependent: :destroy
  has_many :jobseeker_profile_views, foreign_key: :jobseeker_id, dependent: :destroy
  has_many :created_applications, foreign_key: :user_id, class_name: JobApplication, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :permissions, dependent: :destroy
  accepts_nested_attributes_for :permissions
  has_one :notification, dependent: :destroy
  has_many :poll_questions, dependent: :destroy
  has_many :poll_results, dependent: :destroy
  has_many :identities, dependent: :destroy
  has_many :calls, dependent: :destroy

  has_many :employer_notifications, dependent: :destroy

  # Folder
  has_many :folders, foreign_key: :creator_id, dependent: :destroy
  has_many :assigned_folders, dependent: :destroy
  has_many :accessable_folders, -> { distinct }, through: :assigned_folders, source: :folder

  # Rating
  has_many :my_ratings, class_name: Rating, source: :rating, foreign_key: :creator_id

  has_many :evaluation_submits

  # has_many :shared_jobseekers, dependent: :nullify

  has_many :sent_shared_jobseekers, class_name: SharedJobseeker, foreign_key: :sender_id
  has_many :received_shared_jobseekers, class_name: SharedJobseeker, foreign_key: :receiver_id
  has_many :sent_jobseekers, class_name: Jobseeker, through: :sent_shared_jobseekers
  has_many :received_jobseekers, class_name: Jobseeker, through: :received_shared_jobseekers

  has_many :organization_users, dependent: :destroy
  has_many :organizations, -> { distinct }, through: :organization_users
  accepts_nested_attributes_for :organizations

  has_many :requisitions, class_name: Requisition, dependent: :nullify
  has_many :requisitions, dependent: :destroy
  has_many :requisitions_active, -> {where(requisitions:  {is_deleted: false})}, foreign_key: "user_id", class_name: "Requisition"
  has_one :offer_approver, dependent: :destroy

  def jobs
    if self.is_hiring_manager?
      Job.where(organization_id: self.all_organization_ids)
    else
      super
    end
  end

  def employer_job_application_status_changes
    managers = self.all_employers_under_me

    JobApplicationStatusChange.where(employer_id: managers.map(&:id))
  end

  def all_position_ids
    self.organizations.map{|org| org.all_position_ids}.flatten
  end

  def all_employers_under_me
    ids = []
    managers = []
    stack = self.organizations.try(:to_a) || []
    while !stack.empty? do
      org = stack.pop
      managers << org.managers
      ids << org.id
      org.children_organizations.each{|org| stack << org}
    end
    managers.flatten.uniq
  end

  def all_organization_ids
    ids = []
    stack = self.organizations.try(:to_a) || []
    while !stack.empty? do
      org = stack.pop
      ids << org.id
      org.children_organizations.each{|org| stack << org}
    end
    ids
  end

  def all_organization_ids_with_interview
    ids = self.all_organization_ids | InterviewCommitteeMember.where(user_id: self.id).map{|i| i.interview.job.organization_id}

    ids
  end

  # No Need medium: "70x90>", thumb: "35x40>"
  has_attached_file :avatar, dependent: :destroy

  validates_attachment_content_type :avatar, content_type: ["image/jpg", "image/jpeg", "image/png", "image/gif", "image/bmp"]


  has_attached_file :document_e_signature, dependent: :destroy

  validates_attachment_content_type :avatar, content_type: ["image/jpg", "image/jpeg", "image/png", "image/gif", "image/bmp"]


  has_attached_file :video, dependent: :destroy

  validates_attachment_content_type :video, content_type: ['video/x-msvideo', 'video/avi', 'video/quicktime',
                                                           'video/3gpp', 'video/x-ms-wmv', 'video/mp4',
                                                           'flv-application/octet-stream', 'video/x-flv',
                                                           'video/mpeg', 'video/mpeg4', 'video/x-la-asf',
                                                           'video/x-ms-asf', 'flv-application/octet-stream',
                                                           'video/flv', 'video/webm']


  has_attached_file :video_screenshot, dependent: :destroy

  validates_attachment_content_type :video_screenshot, content_type: ["image/jpg", "image/jpeg", "image/png", "image/gif", "image/bmp"]

  GENDER = %w(not_defined male female)
  GENDER_CHAR = %w(N M F)

  #ROLES = %w(jobseeker company_owner company_user company_admin recruiter)
  #ROLES = Role.all

=begin
  User::ROLES.each do |role|
    define_method("is_#{role_val}?") { self.role_id == role.id }
  end
=end

=begin
  def is_employer?
    %w(company_owner company_user company_admin recruiter).include?(self.role)
  end

  def is_company_owner?
    %w(company_owner).include?(self.role)
  end

  def is_recruiter?
    %w(recruiter).include?(self.role)
  end

=end

  def is_company_user?
    true
  end

  def is_company_admin?
    # self.role_id == Role.find_by_name('company_admin').try(:id) || 1
    self.role_id == Role.find_by_name(Role::SUPER_ADMIN).try(:id)
  end

  def is_jobseeker?
    false && self.role_id == Role.find_by_name(Role::JOBSEEKER).try(:id)
  end

  def is_employer?
    true
  end

  def is_company_owner?
    # self.role_id == Role.find_by_name('company_owner').try(:id) || 1
    self.role_id == Role.find_by_name(Role::SUPER_ADMIN).try(:id)
  end

  def is_hiring_manager?
    self.role_id == Role.find_by_name(Role::HIRING_MANAGER).try(:id)
  end

  def is_recruiter?
    self.role_id == Role.find_by_name(Role::RECRUITER).try(:id)
  end

  def is_hr_recruiter?
    self.role_id == Role.find_by_name(Role::GENERAL_DEPARTMENT_RECRUITMENT_OFFICER).try(:id)
  end


  # Role.all.each do |role|
  #   define_method("is_#{role.name.downcase.gsub(/[\ \-]/, '_')}?") { self.role_id == role.id }
  # end
  Role::ROLES.each do |role_name|
    define_method("is_#{role_name.downcase.gsub(/[\ \-]/, '_')}?") { self.role.try(:name) == role_name }
  end

  Role::ROLES.each do |role_name|
    scope role_name.downcase.gsub(/[\ \-]/, '_'), -> { where(role_id: Role.find_by_name(role_name).id) }
  end

  scope :last_approver, -> { where(is_last_approver: true) }

  scope :support_manager, -> { find_by(role_id: Role.find_by_name("On-Boarding Support Management System Representative").id) }
  scope :performance_evaluation, -> { find_by(role_id: Role.find_by_name("On-Boarding Performance Evaluation Representative").id) }
  scope :session_representative, -> { find_by(role_id: Role.find_by_name("On-Boarding MOD Session Representative").id) }

  scope :onboarding_team, -> { where(role_id: Role.onboarding_team.pluck(:id)) }

  # def is_recruiter?
  #   # self.role_id == Role.find_by_name('recruiter').try(:id) || 2
  #   self.role_id == Role.find_by_name(Role::RECRUITER).try(:id)
  # end


  def is_from_internal_team?
    # self.email.include? Rails.application.secrets[:ATS_NAME]["domain_in_internal_emails"]
  end

  def id_6_digits
    '%06d' % self.id
  end

  scope :jobseekers, -> { where(role: 'jobseeker') }
  scope :order_by_desc, -> {  order("id DESC") }
  scope :company_owners, -> { where(role: 'company_owner') }
  scope :company_admins, -> { where(role: 'company_admin') }
  scope :company_users, -> { where(role: 'company_user') }
  scope :recruiters, -> { where(role_id: Role.find_by_name(Role::RECRUITER).try(:id)) }
  scope :security_clearence_officers, -> { where(role_id: Role.find_by_name(Role::SECURITY_CLEARANCE_OFFICER).try(:id)) }
  scope :recruiter, -> { where(role: 'recruiter') }
  scope :employers, -> { where(role: Role::ROLES[0..-2])}
  scope :existing, -> { where(deleted: false) }
  scope :active, -> { where(active: true) }
  scope :is_recruiter, -> { where(role_id: Role.find_by_name(Role::RECRUITER).try(:id)) }
  scope :confirmed, -> { where.not(confirmed_at: nil) }
  scope :male, -> { where(gender: 1) }
  scope :female, -> { where(gender: 2) }
  scope :get_appliers_of_job_group_by_age, -> (job) { where("users.birthday IS NOT NULL").where(id: job.applicants.map(&:user_id)).group("DATE_TRUNC('year', birthday)").count }
  scope :get_appliers_of_job_group_by_age_req, -> (job, applied_jobseeker_ids) { where("users.birthday IS NOT NULL").where(id: job.applicants.where(id: applied_jobseeker_ids).map(&:user_id)).group("DATE_TRUNC('year', birthday)").count }
  scope :get_followers_of_company_group_by_age, -> (company) { where("users.birthday IS NOT NULL").where(id: company.followers.map(&:user_id)).group("DATE_TRUNC('year', birthday)").count }

  # Notifications
  scope :order_by_jobs, -> {  joins(:jobs).group("countries.id").order("count(jobs.id) DESC") }
  scope :daily_notify_jobs, -> { active.existing.where(id: Notification.daily_notification_jobs.pluck(:user_id)) }
  scope :weekly_notify_jobs, -> { active.existing.where(id: Notification.weekly_notification_jobs.pluck(:user_id)) }
  scope :monthly_notify_jobs, -> { active.existing.where(id: Notification.monthly_notification_jobs.pluck(:user_id)) }

  scope :daily_notify_polls, -> { active.existing.where(id: Notification.daily_notification_polls.pluck(:user_id)) }
  scope :weekly_notify_polls, -> { active.existing.where(id: Notification.weekly_notification_polls.pluck(:user_id)) }
  scope :monthly_notify_polls, -> { active.existing.where(id: Notification.monthly_notification_polls.pluck(:user_id)) }

  scope :daily_notify_blogs, -> { active.existing.where(id: Notification.daily_notification_blogs.pluck(:user_id)) }
  scope :weekly_notify_blogs, -> { active.existing.where(id: Notification.weekly_notification_blogs.pluck(:user_id)) }
  scope :monthly_notify_blogs, -> { active.existing.where(id: Notification.monthly_notification_blogs.pluck(:user_id)) }

  scope :daily_notify_candidates, -> { active.existing.where(id: Notification.daily_notification_candidates.pluck(:user_id)) }
  scope :weekly_notify_candidates, -> { active.existing.where(id: Notification.weekly_notification_candidates.pluck(:user_id)) }
  scope :monthly_notify_candidates, -> { active.existing.where(id: Notification.monthly_notification_candidates.pluck(:user_id)) }


  # This Scope created only for rake task to send some specific mails to some users
  scope :jobseekers_in_selected_cities_with_specific_nationalities, -> (cities, nationalities) {
    joins("LEFT JOIN jobseekers ON jobseekers.user_id = users.id")
        .where("users.city_id IN (?) AND jobseekers.nationality_id IN (?)", (cities.map(&:id) << -1), (nationalities.map(&:id) << -1))
  }

  validates :auth_token, uniqueness: true
  # Instead of validatable
  validates_uniqueness_of    :email, case_sensitive: false, allow_blank: true, if: :email_changed?
  validates_format_of    :email, with: Devise.email_regexp, allow_blank: true, if: :email_changed?
=begin
  validates_presence_of    :password, on: :create
  validates_confirmation_of    :password
  validates_length_of    :password, within: Devise.password_length, allow_blank: true
=end

  attr_accessor :skip_validation
  # attr_accessor :skip_validation_birth

  # TODO: Add last_name after clean DB
  validates_presence_of :email, :first_name
  validates_presence_of :last_name, unless: :skip_validation
  # validates_presence_of :birthday, unless: :skip_validation_birth
  #validates_presence_of :birthday, on: :update, unless: Proc.new{|u| u.encrypted_password_changed? || u.is_employer? }
  #validates_presence_of :birthday, on: :create, if: Proc.new{|u| u.is_employer? }

  # validates :email, presence: true, on: :create
  # validates :password, presence: true, on: :create
  before_create :generate_authentication_token!
  after_update :confirm_account, if: Proc.new{|u| u.is_jobseeker? && u.encrypted_password_changed? && u.confirmed_at.blank? }

  def top_organization
    org_types = self.organizations.map(&:organization_type)
    top_organization_type = org_types.min_by(&:order)
    self.organizations.find_by(organization_type_id: top_organization_type.id)
  end

  def gender_type
    User::GENDER[self.gender || 0]
  end

  def gender_char
    User::GENDER_CHAR[self.gender || 0]
  end

  def is_male?
    self.gender == 1
  end

  def is_female?
    self.gender == 2
  end

  def set_auth_token
    if self.auth_token.blank?
      self.generate_authentication_token!
      self.save(validate: false)
    end
  end

  def generate_authentication_token!
    begin
      self.auth_token = Devise.friendly_token
    end while self.class.exists?(auth_token: auth_token)
  end

  # Update last active & push to algolia
  def update_last_active
    if self.last_active.nil? || (DateTime.now.to_date - self.last_active.to_date).to_i > 0
      self.update_column(:last_active, DateTime.now)
    end
  end

  def upload_profile_image profile_image_base
    self.avatar  = profile_image_base
    self.save!
  end

  def self.recruiters_for_job job
    rec_list = []
    User.recruiters.each_with_index do |sel_user, index|
      if sel_user.all_organization_ids.include?(job.organization.id)
        rec_list << sel_user
      end
    end
    rec_list
  end



  def full_name
    "#{self.first_name} #{self.last_name}"
  end

  def name
    "#{self.first_name} #{self.last_name}"
  end

  def is_job_offer_approver?
    OfferApprover.all.map(&:user_id).include?(self.id)
  end

  def accessable_job_ids
    job_ids = []
    # if self.is_job_offer_approver? && !(self.is_recruiter? || self.is_recruitment_manager?)
    if self.is_job_offer_approver? && !(self.is_recruitment_manager?)
      job_ids |= JobApplication.job_offer.pluck(:job_id)
    end

    if self.is_interviewer?
      job_ids |= InterviewCommitteeMember.where(user_id: self.id).map{|i| i.interview.job.id}
      job_ids << -1
    elsif self.is_assessor? || self.is_assessor_coordinator?
      job_ids |= JobApplication.assessment_security_clearance_job_offer.pluck(:job_id)
      job_ids << -1
    elsif self.is_qec_coordinator?
      job_ids |= JobApplication.assessment_security_clearance_job_offer.where(employment_type: 'internal').pluck(:job_id)
      job_ids << -1
    elsif self.is_security_clearance_officer?
      job_ids |= JobApplication.assessment_security_clearance_job_offer.pluck(:job_id)
      job_ids << -1
    elsif self.is_recruiter?
      job_ids |= Job.where(organization_id: self.all_organization_ids).pluck(:id)
      job_ids << -1
    elsif self.is_hiring_manager? || self.is_hr_recruiter?
      job_ids |= Job.where(organization_id: self.all_organization_ids).pluck(:id)
      job_ids |= JobApplication.where("shared_with_hiring_manager = ? AND user_id = ?", true, self.id).pluck(:job_id)
      job_ids |= InterviewCommitteeMember.where(user_id: self.id).map{|i| i.interview.job.id}
      job_ids |= Requisition.where(user_id: self.id).pluck(:job_id)
      job_ids << -1
    elsif Role.where(name: Role::ON_BOARDING_ROLES).map(&:id).include?(self.role_id)
      job_ids |= JobApplication.onboarding.pluck(:job_id)
      job_ids << -1
    end

    if !job_ids.blank?
      job_ids << -1
    end

    job_ids
  end


  def has_permission_to_job job
    self.all_organization_ids.include?(job.organization.id)
  end

  # This ransacker to concat first_name & last_name
  ransacker :full_name, formatter: proc { |v| v.mb_chars.downcase.to_s } do |parent|
    Arel::Nodes::NamedFunction.new('LOWER',
                                   [Arel::Nodes::NamedFunction.new('concat_ws',
                                                                   [Arel::Nodes.build_quoted(' '), parent.table[:first_name], parent.table[:last_name]])])
  end

  def change_status status
    self.active = (status === 'activate')
    is_saved = self.save!
    self.update_column(:confirmed_at, DateTime.now) if self.confirmed_at.nil?

    # if !self.active && is_saved
    #   if self.is_employer?
    #     self.deactivate_employer
    #   else
    #     self.deactivate_jobseeker
    #   end
    # end
    is_saved
  end

  # This method to convert permissions to be compressed array
  def permissions_names
    if self.is_company_owner?
      return CompanyUser::PERMISSIONS.keys
    end

    self.permissions.map(&:name).uniq
  end

  # TODO: change these methods when user has many companies
  def company
    self.companies.first
  end

  def employer
    self.company_users.first
  end

  def current_role
    self.is_employer? ? "employer" : "jobseeker"
  end

  def interviews
    # self.is_jobseeker? ? Interview.where(job_application_status_change_id: JobApplicationStatusChange.where(jobseeker_id: self.id).pluck(:id)) : Interview.where(job_application_status_change_id: JobApplicationStatusChange.where(employer_id: self.id).pluck(:id))
    #self.is_jobseeker? ? Interview.where(job_application_status_change_id: JobApplicationStatusChange.where(jobseeker_id: self.id).pluck(:id)) : Interview.where(interviewer_id: self.id)
  end

  def current_jobseeker_company
    self.is_jobseeker? ? self.jobseeker.current_company : nil
  end

  # Send company_user or company_admin as params
  def can_delete user_account
    return false if user_account.is_company_owner? || user_account.is_jobseeker?
    return true if self.is_company_owner? && (user_account.is_company_admin? || user_account.is_company_user?)
    return true if self.is_company_admin? && user_account.is_company_user?
  end

  def status
    res = ""
    if !self.active || self.confirmed_at.nil?
      res = "Inactive" unless self.active
      res = self.confirmed_at.nil? ? "#{res} Non-Confirmed" : "#{res} Confirmed"
    elsif self.active
      if self.is_jobseeker?
        res = "Active #{self.jobseeker.is_completed? ? 'Complete' : 'Non-Complete'}"
      else
        res = "Active"
      end
    end
    res
  end

  def send_video_notification
    vars = [{name: "profilename", content: self.full_name},
            {name: "profilelink", content: "http://52.44.177.10/jobseekers/#{self.jobseeker.id}"}]


    email_to = Rails.application.secrets['OWNER_TEAM']
    email_from = Rails.application.secrets['SENDER_EMAIL']

    self.send_email_template("video_profile_upload"  , vars ,email_to , email_from , "Video upload by #{self.full_name}")
  end

  # This method to send notification to admin guys
  def send_notification_to_admin
    company = self.companies.first

    vars = [{name: "company_name", content: company.name},
            {name: "company_country", content: company.country_name},
            {name: "owner_name", content: self.full_name},
            {name: "owner_email", content: self.email},
            {name: "company_phone", content: company.phone},
            {name: "created_date", content: company.created_at.in_time_zone('Abu Dhabi').strftime("%d %b, %Y")},
            {name: "created_time", content: company.created_at.in_time_zone('Abu Dhabi').strftime("%I:%M %p")}]

    admin_emails = Rails.application.secrets['BUSINESS_TEAM']

    email_from = Rails.application.secrets['SENDER_EMAIL']

    self.delay.send_email_template("employer_registration", vars, admin_emails, email_from, "BLOOVO.COM | New Employer")
  end

  def sending
    smtp = Net::SMTP.new('smtp.outlook.com', 587)
    smtp.start("bloovo.com", "no-reply@bloovo.com", "noreply@2020", :plain) do |smtp|
      smtp.send_message "HELLO", 'no-reply@bloovo.com', ['myakout@bloovo.com']
    end
  end

  # def pony_send
  #   Pony.mail({
  #       :to => 'bloovo2017@gmail.com',
  #       :via => :smtp,
  #       :subject => 'hi', :body => 'Hello there.',
  #       :via_options => {
  #           :address              => 'smtp.outlook.com',
  #           :port                 => '587',
  #           :enable_starttls_auto => true,
  #           :user_name            => 'no-reply@bloovo.com',
  #           :password             => 'noreply@2020',
  #           :authentication       => :plain, # :plain, :login, :cram_md5, no auth by default
  #           :domain               => "bloovo.com" # the HELO domain provided by the client to the server
  #       }
  #   })
  # end

  def mail_send
    mail = Mail.new do
      from    'no-reply@bloovo.com'
      to      'bloovo2017@gmail.com'
      subject 'Any subject you want'
      body    'Lorem Ipsum'
    end

    mail.delivery_method :sendmail

    mail.deliver
  end

  def send_mail_by_c_sharp
    begin
      system("dotnet run --project #{Rails.root.to_path}/sending_mails #{self.email}" )




      # generate_url("#{Rails.application.secrets['ETHRA_URL']}/mol/Default.aspx", {tkn: tkn, lgn: lgn})
      return "#{Rails.application.secrets['ETHRA_URL']}?tkn=#{tkn}&lgn=#{lgn}"
    rescue Exception => e
      puts e.message
      return nil
    end
  end

  def self.new_refresh_mails
    command = "dotnet run --project #{Rails.root.to_path}/sending_mails #{Rails.application.secrets['SENDER_EMAIL']} #{Rails.application.secrets['SENDER_EMAIL_PASSWORD']} #{Rails.application.secrets['DOMAIN']} #{Rails.application.secrets['SENDER_EMAIL_SMTP']} #{Rails.application.secrets['SENDER_EMAIL_PORT']} #{Rails.root.to_path}/sending_mails/mails_content/test.txt"
    puts command
    system(command)
  end

  def self.refresh_mails
    Dir.foreach('sending_mails/mails_content') do |filename|
      next if filename == '.' or filename == '..'
      puts filename
      command = "dotnet run --project #{Rails.root.to_path}/sending_mails #{Rails.application.secrets['SENDER_EMAIL']} #{Rails.application.secrets['SENDER_EMAIL_PASSWORD']} #{Rails.application.secrets['DOMAIN']} #{Rails.application.secrets['SENDER_EMAIL_SMTP']} #{Rails.application.secrets['SENDER_EMAIL_PORT']} #{Rails.root.to_path}/sending_mails/mails_content/#{filename}"
      puts command
      system(command)
    end
  end

  def self.find_for_oauth(auth, signed_in_resource = nil)

    # Get the identity and user if they exist
    return nil if auth.nil?
    identity = Identity.find_for_oauth(auth)

    # If a signed_in_resource is provided it always overrides the existing user
    # to prevent the identity being locked with accidentally created accounts.
    # Note that this may leave zombie accounts (with no associated identity) which
    # can be cleaned up at a later date.
    user = signed_in_resource ? signed_in_resource : identity.user
    # Create the user if needed
    if user.nil?

      # Get the existing user by email if the provider gives us a verified email.
      # If no verified email was provided we assign a temporary email and ask the
      email = auth.info.email
      user = User.where(email: email).first if email

      # Create the user if it's a new registration
      names = auth.info.name.present? ? auth.info.name.split(" ") : []
      f_name = auth.info.first_name || names[0]
      l_name = auth.info.last_name || names[1]

      if user.nil? && email.present?
        user = User.new(
            first_name: f_name,
            last_name: l_name,
            email: email,
            password: Devise.friendly_token[0,20],
            role: "jobseeker",
            active: true,
            deleted: false
        )
        user.skip_confirmation!
        if user.save(validate: false)
          jobseeker = Jobseeker.new(user_id: user.id, complete_step: 0)
          jobseeker.save(validate: false)
        end
      elsif user.present? && user.is_employer?
        # No Identity for employers ... (Just allow to login if exist employer)
        identity.destroy
        return user
      elsif email.blank?
        #   FB & TW without email
        return {
            first_name: f_name,
            last_name: l_name,
            errors: [{email: "can't be blank"}]
        }
      end
    end

    # Associate the identity with the user if needed
    if identity.user != user
      identity.user = user
      identity.save!
    end
    user
  end

  def top_organization
    self.organizations.max_by {|obj| obj.organization_type.try(:order) }
  end

  def parent_organization_ids
    ids = []
    stack = self.organizations.try(:to_a) || []
    while !stack.empty? do
      org = stack.pop
      ids << org.id
      if org.parent_organization
        stack << org.parent_organization
      end
    end
    ids
  end

  def all_parent_children_organizations_ids
    children_organization_ids = self.all_organization_ids
    parent_organization_ids = self.parent_organization_ids
    (children_organization_ids | parent_organization_ids | [-1]).uniq
  end

  def confirm_account
    self.update_column(:confirmed_at, Date.today)
  end

  # TODO: Remove this struct .. this struct to update exist users with previous image & video & video_screen
  UploadAvatar = Struct.new(:user, :avatar_path) do
    def perform
      user.avatar = File.open(avatar_path)
      user.save
    end
  end

  UploadVideo = Struct.new(:user, :video_path) do
    def perform
      user.video = File.open(video_path)
      user.save
    end
  end


  UploadVideoScreenshot = Struct.new(:user, :video_screenshot_path) do
    def perform
      user.video_screenshot = File.open(video_screenshot_path)
      user.save
    end
  end
end
