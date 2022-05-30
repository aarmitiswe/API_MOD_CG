require 'fuzzy_match'
require "csv"

class Job < ActiveRecord::Base
  include Pagination
  include SearchParams
  include EmployerJobseekerWeight
  include MatchingPercentage
  include SendInvitation
  include RequisitionBuilder
  include ExportBuilder

  attr_accessor :probability_success, :probability
  after_initialize :init
  after_save :check_if_deleted

  belongs_to :company
  belongs_to :branch
  belongs_to :job_type
  belongs_to :job_status
  belongs_to :job_category
  belongs_to :functional_area
  belongs_to :sector
  belongs_to :job_education
  belongs_to :job_experience_level
  belongs_to :visa_status
  belongs_to :country
  belongs_to :city
  belongs_to :user
  belongs_to :latest_changor_user, foreign_key: :latest_changor_user_id, class_name: User

  # Age & Salary
  belongs_to :salary_range
  belongs_to :age_group
  # JobApplication
  has_many :job_applications, dependent: :destroy
  has_many :job_applications_status_changes, through: :job_applications
  has_many :applicants, through: :job_applications, source: :jobseeker
  has_one :job_request
  # Tags
  has_many :job_tags, dependent: :destroy
  has_many :tags, through: :job_tags
  # Languages
  has_many :job_languages, dependent: :destroy
  has_many :languages, through: :job_languages
  # Benefit
  has_many :job_benefits, dependent: :destroy
  has_many :benefits, through: :job_benefits
  # Skills
  has_many :job_skills, dependent: :destroy
  has_many :skills, through: :job_skills
  # Certificates
  has_many :job_certificates, dependent: :destroy
  has_many :certificates, through: :job_certificates

  has_many :suggested_candidates, dependent: :destroy
  has_many :suggested_jobseekers, through: :suggested_candidates, source: :jobseeker

  # Geo Groups
  # has_many :job_geo_groups, dependent: :destroy
  # has_many :geo_groups, through: :job_geo_groups
  # has_many :country_geo_groups, through: :geo_groups
  # has_many :geo_countries, through: :country_geo_groups, source: :country

  has_many :job_countries, dependent: :destroy
  has_many :geo_countries, through: :job_countries, source: :country
  has_many :job_histories, dependent: :destroy
  belongs_to :organization
  has_many :requisitions, dependent: :destroy
  has_many :requisitions_active, -> {where(requisitions:  {is_deleted: false})}, foreign_key: "job_id", class_name: "Requisition"
  has_many :job_recruiters, dependent: :destroy
  accepts_nested_attributes_for :job_recruiters, allow_destroy: true


  has_many :recruiters, through: :job_recruiters, source: :user

  belongs_to :position
  # Validates
  #validates_presence_of :title, :description, :job_type_id, :start_date, :end_date, :country_id, :city_id, :company_id,
  #                      :requirements, unless: lambda { |job| job.job_status_id == JobStatus.find_by_status('Draft').id }
  #@toDo: Thowing error for draft job without City, Check Yakout
  #validates_inclusion_of :city_id, in: lambda { |job| job.country.cities.map(&:id).flatten }, unless: lambda { |job| job.job_status_id == JobStatus.find_by_status('Draft').id }


  #validate :end_date_is_after_start_date
  #validate :experience_from_is_less_experience_to
  #validate :join_date_after_today
  validate :position_oracle_id

  # Callbacks
 # after_create :set_suggested_candidates, on: :create

  scope :deleted, -> { where(deleted: true) }
  scope :closed, -> { where(job_status_id: 3) }
  scope :open, -> { where(job_status_id: 2) }
  scope :draft, -> { where(job_status_id: 1) }
  scope :not_draft, -> { where.not(job_status_id: 1) }
  scope :expired, -> { where("end_date < ?", Date.today).where(job_status_id: 2, deleted: false) }
  scope :unexpired, -> { where("end_date >= ?", Date.today) }
 # scope :old_jobs, -> { where("created_at <= 'Wed, 12 Feb 2020'") }
  scope :started, -> { where("start_date <= ?", Date.today) }
  scope :featured, -> { where(is_featured: true) }
  scope :unfeatured, -> { where(is_featured: false) }
  scope :not_graduate_program, -> { where('title != ?', 'graduate_program') }
  scope :active, -> {
    #TODO apply only unexpired before release
    where(active: true, job_status_id: 2, deleted: false).started.unexpired
    # where(active: true, job_status_id: 2).started.unexpired
  }

  scope :external_hiring, -> { where(is_internal_hiring: false) }
  scope :internal_hiring, -> (current_user) { Rails.application.secrets[:ATS_NAME]["has_internal_hiring"] && current_user && current_user.is_jobseeker? && current_user.is_from_internal_team? ? where("is_internal_hiring IS TRUE OR is_internal_hiring is FALSE") : where(is_internal_hiring: false) }

  # scope :internal, -> { where(position_id: Position.internal.pluck(:id)) }
  # scope :external, -> { where(position_id: Position.external.pluck(:id)) }
  # scope :both, -> { where(position_id: Position.both.pluck(:id)) }

  scope :internal, -> { where(employment_type: "internal") }
  scope :external, -> { where(employment_type: "external") }
  scope :both, -> { where(employment_type: "both") }

  scope :none_notify_applicants, -> { where(notification_type: 0) }
  scope :all_notify_applicants, -> { where(notification_type: 1) }
  scope :weekly_notify_applicants, -> { where(notification_type: 2) }
  scope :daily_notify_applicants, -> { where(notification_type: 3) }
  # Analysis Jobs By Date
  scope :monthly, -> { where("created_at > ?", 1.year.ago).group("TO_CHAR(DATE_TRUNC('month', created_at), 'MON')").count }
  # scope :monthly, -> { where("created_at > ?", 1.year.ago).group("TO_CHAR(created_at, 'Month YYYY')").count }
  scope :quarterly, -> { where("created_at > ?", Date.today.beginning_of_year).group("extract(quarter from created_at)").count }
  # scope :yearly, -> { where("created_at > ?", 12.year.ago).group("DATE_TRUNC('year', created_at)").count }
  scope :yearly, -> { where("created_at > ?", 12.year.ago).group("TO_CHAR(DATE_TRUNC('year', created_at), 'YYYY')").count }

  scope :assessor_jobs, -> { where(position_id: Position.assessor_positions.pluck(:id)) }
  scope :not_rejected, -> { where.not(requisition_status: 'rejected').where.not(requisition_status: nil) }
  scope :without_job_applications, -> { where("(select count(*) from job_applications where job_id=jobs.id) = 0") }
  scope :with_job_applications, -> { where("(select count(*) from job_applications where job_id=jobs.id) > 0") }



  JOBSEEKER_FIELDS_ANALYSIS = %w(country job_education sector nationality gender)
  GENDER = %w(any male female)
  EMPLOYMENT_TYPE_MAIL = {
      "internal" => "تكليف داخلي",
      "external" => "استقطاب خارجي",
      "both" => "تكليف داخلي او استقطاب خارجي"
  }

  # This loop to define method for analysis for country, job_education, sector
  # It's called by serializer of job for jobseeker only
  Job::JOBSEEKER_FIELDS_ANALYSIS.each do |field_name|
    define_method("analysis_applications_by_#{field_name}") do |language, applied_jobseeker_ids, is_gp = false|

      #@Todo: pass is_gp . Quick fix for merge
      # is_gp = false

      if (is_gp)
        field_id_with_count = Jobseeker.matched_criteria_graduate_program.send("grouped_by_#{field_name}", self)
      elsif Rails.application.secrets[:ACTIVATE_REQUISITION]
        field_id_with_count = Jobseeker.send("req_grouped_by_#{field_name}", self, applied_jobseeker_ids)
      else
        field_id_with_count = Jobseeker.send("grouped_by_#{field_name}", self)
      end

      field_id_percentage = {}
      column_name = language == "ar" ? "ar_name" : "name"

      field_id_with_count.each do |field_id, num|
        if field_name == 'nationality'
          new_key = Country.find_by_id(field_id).try(:send, column_name)
        elsif field_name == 'gender'
          new_key = field_id
        else
          new_key = field_name.camelcase.constantize.find_by_id(field_id).try(:send, column_name)
        end
        # field_id_percentage[new_key] = num * 100 / self.count_applications
        field_id_percentage[new_key] = num
      end
      field_id_percentage
    end
  end

  JobStatus.all.each do |job_status|
    define_method("is_#{job_status.status.parameterize.underscore}?") { self.job_status_id == job_status.id }
  end

  # this method to return each year birthyear & count appliers {"01-01-1991": 33, ..}
  def analysis_applications_by_age
    User.get_appliers_of_job_group_by_age(self)
  end

  def analysis_applications_by_age_gp
    User.get_appliers_of_job_group_by_age_gp(self)
  end

  def analysis_applications_req_by_age(applied_jobseeker_ids)
    User.get_appliers_of_job_group_by_age_req(self, applied_jobseeker_ids)
  end

  def gender_type
    self.gender && self.gender > 0 ? Job::GENDER[self.gender] : nil
  end


  def ar_employment_type
    self.position.try(:ar_employment_type)
  end

  def hiring_manager
    self.organization.managers.first
  end

  # Class Methods
  class << self
    def by_country
      group(:country).count
    end

    def by_sector
      group(:sector).count
    end

    def applicants_in_range job, start_matching_percentage, end_matching_percentage
      @applicants = Jobseeker.calculate_matching_percentage(job, {id_in: (job.applicant_ids << -1)}, start_matching_percentage, end_matching_percentage)
    end
  end

  def applicants_users
    User.where(id: self.applicants.map(&:user_id))
  end

  def count_applications
    self.job_applications.count
  end

  def can_unlock?
    self.job_applications.where.not(job_application_status_id: JobApplicationStatus.where(status: ['OnBoarding', 'Completed']).pluck(:id)).count == 0
  end

  def status
    self.job_status.status
  end

  def similar_jobs_by_fields
    similar_sector_ids = self.sector ? self.sector.similar_sectors.map(&:id) : Sector.all.map(&:id)
    # Remove functional_area_id: self.functional_area_id || FunctionalArea.all.map(&:id)
    Job.active.where.not(id: self.id).where(country_id: self.country_id,
                                            city_id: self.city_id || self.country.cities.map(&:ids),
                                            sector_id: self.sector_id || similar_sector_ids)
  end

  def similar_jobs
    FuzzyMatch.new(self.similar_jobs_by_fields, read: :title, must_match_at_least_one_word: true).find_all_with_score(self.title).map { |arr| arr[0...arr.count - 2] }.flatten
  end

  def similar_companies
    similar_sector_ids = self.sector ? self.sector.similar_sectors.map(&:id) : Sector.all.map(&:id)
    Company.active.where(current_country_id: self.company.country_ids || self.company.current_country_id || self.country_id,
                         current_city_id: self.company.current_city_id || self.city_id || self.country.cities.map(&:id),
                         sector_id: self.company.sector_id || self.sector_id || similar_sector_ids).where.not(id: self.company_id)
  end

  def applied_date user
    return nil if user.nil?
    jobseeker = user.jobseeker
    self.job_applications.find_by(jobseeker_id: jobseeker.id).try(:created_at) unless jobseeker.nil?
  end

  def is_saved_by_user user
    jobseeker = user.jobseeker
    !SavedJob.find_by(job_id: self.id, jobseeker: jobseeker.try(:id)).nil?
  end

  def is_applied_by_user user
    !self.applied_date(user).nil?
  end

  def increase_viewers
    self.views_count ||= 0
    self.views_count += 1
    self.save(validate: false)
  end

  def position_status
    if self.position.present? && self.position.position_status.present?
      return self.position.position_status.ar_name
    else
      return "-"
    end
  end

  def nationality
    self.geo_countries.map(&:name).join(",")
  end

  # certificates are [{id: 1, name: "CCNA"}, {id: null, name: "ICDL"}]
  def add_certificates new_certificates
    return true if new_certificates.nil?
    exist_job_certificate_ids = []
    new_certificate_ids = []

    new_certificates.each do |certificate|
      new_certificate = if certificate[:id].nil?
                          Certificate.find_or_create_by(name: certificate[:name])
                        else
                          Certificate.find_by_id(certificate[:id])
                        end

      unless self.certificate_ids.include?(new_certificate.id)
        weight = new_certificate.weight || 0
        new_certificate.update_attribute(:weight, weight + Job::EMPLOYER_WEIGHT)

        new_certificate_ids.push({job_id: self.id, certificate_id: new_certificate.id})
      else
        exist_job_certificate_ids.push(JobCertificate.find_by(job_id: self.id, certificate_id: new_certificate.id).id)
      end
    end
    #  Delete associated certificates
    deleted_job_certificate_ids = self.job_certificate_ids - exist_job_certificate_ids
    deleted_job_certificates = JobCertificate.where(id: deleted_job_certificate_ids)
    Certificate.where(id: deleted_job_certificates.map(&:certificate_id))
        .map { |cer| cer.update_attribute(:weight, cer.weight - Job::EMPLOYER_WEIGHT) if cer.weight >= Job::EMPLOYER_WEIGHT }

    JobCertificate.where(id: deleted_job_certificate_ids).destroy_all

    # Create new job_certificates
    JobCertificate.create(new_certificate_ids)
  end

  # skills are [{id: 1, name: "Development"}, {id: null, name: "ICDL"}]
  def add_skills new_skills
    return true if new_skills.nil?
    exist_job_skill_ids = []
    new_skill_ids = []

    new_skills.each do |skill|
      new_skill = if skill[:id].nil?
                    Skill.find_or_create_by(name: skill[:name])
                  else
                    Skill.find_by_id(skill[:id])
                  end

      unless self.skill_ids.include?(new_skill.id)
        weight = new_skill.weight || 0
        new_skill.update_attribute(:weight, weight + Job::EMPLOYER_WEIGHT)

        new_skill_ids.push({job_id: self.id, skill_id: new_skill.id})
      else
        exist_job_skill_ids.push(JobSkill.find_by(job_id: self.id, skill_id: new_skill.id).id)
      end
    end
    #  Delete associated skills
    deleted_job_skill_ids = self.job_skill_ids - exist_job_skill_ids
    deleted_job_skills = JobSkill.where(id: deleted_job_skill_ids)
    Skill.where(id: deleted_job_skills.map(&:skill_id))
        .map { |sk| sk.update_attribute(:weight, sk.weight - Job::EMPLOYER_WEIGHT) if sk.weight >= Job::EMPLOYER_WEIGHT }

    JobSkill.where(id: deleted_job_skill_ids).destroy_all

    # Create new job_skills
    JobSkill.create(new_skill_ids)
  end

  def jobseeker_ids_has_common_languages
    jobseeker_ids = JobseekerLanguage.where(language_id: self.language_ids).pluck(:jobseeker_id).uniq
    jobseeker_ids.blank? ? [-1] : jobseeker_ids
  end

  def jobseeker_ids_has_common_skills
    jobseeker_ids = JobseekerSkill.where(skill_id: self.skill_ids).pluck(:jobseeker_id).uniq
    jobseeker_ids.blank? ? [-1] : jobseeker_ids
  end

  def jobseeker_ids_has_common_title
    jobseeker_ids = JobseekerExperience.where(position: self.title).pluck(:jobseeker_id).uniq
    jobseeker_ids.blank? ? [-1] : jobseeker_ids
  end

  def set_suggested_candidates
    return unless self.suggested_jobseekers.blank?

    # TODO: Add active condition here
    applicants_ids = JobApplication.where(job_id: self.id).pluck(:jobseeker_id) || []
    suggested_candidates = Jobseeker.calculate_matching_percentage(self, {id_not_in: (applicants_ids << -1)}, 50, 100).first(50)

    suggested_candidates_records = []
    suggested_candidates.each do |jobseeker|
      suggested_candidates_records.push({
                                            job_id: self.id,
                                            jobseeker_id: jobseeker.id,
                                            matching_percentage: jobseeker.matching_percentage
                                        })
    end

    SuggestedCandidate.create(suggested_candidates_records)
  end


  def check_if_deleted
    if  self.deleted == true
      if self.job_request.try(:deleted) == false
        self.job_request.update(deleted: true)
      end
      self.send_delete_notification_to_creator
    end
  end

  def update_log_history current_user, action
    self.job_histories.create({job_action_type: action, user_id: current_user.id})
  end

  def send_cancellation_email_to_requisition
    templates_values = {
      CreatedDate: self.created_at.strftime("%d %b, %Y"),
      Subject: "Job Organization Has been Changed",
      CreatorName: self.user.first_name,
      CompanyName: self.company.name,
      RemoverName: self.try(:latest_changor_user).try(:first_name),
      TitleJob: self.title,
      JobURL: "#{Rails.application.secrets[:FRONTEND]}/employer/jobs/#{self.id}",
      URLRoot: Rails.application.secrets[:BACKEND],
      Website: Rails.application.secrets[:FRONTEND],
      MainLogo: "#{Rails.application.secrets[:BACKEND]}/email_templates/mail-logo.png",
      primaryColor: Rails.application.secrets[:ATS_CSS]["colors"]["primary"],
      secondaryColor: Rails.application.secrets[:ATS_CSS]["colors"]["secondary"],
      lightBg: Rails.application.secrets[:ATS_CSS]["colors"]["lightBg"],
      borderColor: Rails.application.secrets[:ATS_CSS]["colors"]["border"],
      WebsiteName: Rails.application.secrets[:ATS_NAME]["website_name"]
    }
    self.requisitions_active.each_with_index do |sel_req, req_index|
      user = sel_req.user
      templates_values[:ApproverName] = user.full_name
      self.send_email "cancel_job_approver",
                      [{email: user.email, name: self.company.name}],
                      {message_body: nil, template_values: templates_values}
    end
    delete_active_requisitions
  end

  def delete_active_requisitions
    self.requisitions_active.update_all(is_deleted:true)
  end


  def share_url params

      templates_values = {
          CreatedDate: self.created_at.strftime("%d %b, %Y"),
          Subject: "Sharing Job",
          CreatorName: self.user.first_name,
          CompanyName: self.company.name,
          CompanyImg: "#{Rails.application.secrets[:BACKEND]}/email_templates/mail-logo.png",
          TitleJob: self.title,
          CopyLinkMessage: params[:share_message],
          JobURL: "#{Rails.application.secrets[:FRONTEND]}/#{self.country.try(:name).try(:parameterize)}/jobs/#{self.city.try(:name).try(:parameterize)}/#{self.sector.try(:name).try(:parameterize)}/#{self.try(:title).try(:parameterize)}-#{self.id}",
          URLRoot: Rails.application.secrets[:BACKEND],
          Website: Rails.application.secrets[:FRONTEND],
          MainLogo: "#{Rails.application.secrets[:BACKEND]}/email_templates/mail-logo.png",
          primaryColor: Rails.application.secrets[:ATS_CSS]["colors"]["primary"],
          secondaryColor: Rails.application.secrets[:ATS_CSS]["colors"]["secondary"],
          lightBg: Rails.application.secrets[:ATS_CSS]["colors"]["lightBg"],
          borderColor: Rails.application.secrets[:ATS_CSS]["colors"]["border"],
          WebsiteName: Rails.application.secrets[:ATS_NAME]["website_name"]
      }

      self.send_email "share_job",
                      [{email: params[:email], name: self.company.name}],
                      {message_body: nil, template_values: templates_values}


  end

  def send_email_to_hiring_manager


    templates_values = {
      CreatedDate: self.created_at.strftime("%d %b, %Y"),
      Subject: "Sharing Job",
      CreatorName: self.user.first_name,
      CompanyName: self.company.name,
      CompanyImg: "#{Rails.application.secrets[:BACKEND]}/email_templates/mail-logo.png",
      JobTitle: self.title,
      HiringManagerName: '',
      JobURL: "#{Rails.application.secrets[:FRONTEND]}/#{self.country.try(:name).try(:parameterize)}/jobs/#{self.city.try(:name).try(:parameterize)}/#{self.sector.try(:name).try(:parameterize)}/#{self.try(:title).try(:parameterize)}-#{self.id}",
      URLRoot: Rails.application.secrets[:BACKEND],
      Website: Rails.application.secrets[:FRONTEND],
      MainLogo: "#{Rails.application.secrets[:BACKEND]}/email_templates/mail-logo.png",
      primaryColor: Rails.application.secrets[:ATS_CSS]["colors"]["primary"],
      secondaryColor: Rails.application.secrets[:ATS_CSS]["colors"]["secondary"],
      lightBg: Rails.application.secrets[:ATS_CSS]["colors"]["lightBg"],
      borderColor: Rails.application.secrets[:ATS_CSS]["colors"]["border"],
      WebsiteName: Rails.application.secrets[:ATS_NAME]["website_name"]
    }

      self.organization.managers.each_with_index do |sel_user|
        templates_values[:HiringManagerName] = sel_user.full_name
        self.send_email "notify_hiring_manager",
                        [{email: sel_user.email, name: sel_user.full_name}],
                        {message_body: nil, template_values: templates_values}
      end




  end

  # @cleve: You need to check the subject & details from Ahmad .. here method to send notification the job is deleted
  def send_delete_notification_to_creator
    if self.deleted?
      templates_values = {
          CreatedDate: self.created_at.strftime("%d %b, %Y"),
          Subject: "A USER HAS DELETED A JOB",
          CreatorName: self.user.first_name,
          CompanyName: self.company.name,
          RemoverName: self.try(:latest_changor_user).try(:first_name),
          TitleJob: self.title,
          JobURL: "#{Rails.application.secrets[:FRONTEND]}/employer/jobs/#{self.id}",
          URLRoot: Rails.application.secrets[:BACKEND],
          Website: Rails.application.secrets[:FRONTEND],
          MainLogo: "#{Rails.application.secrets[:BACKEND]}/email_templates/mail-logo.png",
          primaryColor: Rails.application.secrets[:ATS_CSS]["colors"]["primary"],
          secondaryColor: Rails.application.secrets[:ATS_CSS]["colors"]["secondary"],
          lightBg: Rails.application.secrets[:ATS_CSS]["colors"]["lightBg"],
          borderColor: Rails.application.secrets[:ATS_CSS]["colors"]["border"],
          WebsiteName: Rails.application.secrets[:ATS_NAME]["website_name"]
      }

      self.send_email "deleted_job",
                      [{email: self.user.email, name: self.user.full_name}],
                      {message_body: nil, template_values: templates_values}

    end
  end


  def get_rank_jobseeker jobseeker
    applicants_ids = (JobApplication.where(job_id: self.id).pluck(:jobseeker_id) || []) << -1
    # TODO: Add active condition here
    new_applicants = Jobseeker.calculate_matching_percentage(self, {id_in: (applicants_ids << jobseeker.id)}, 0, 100, "matching_percentage")
    new_applicants.each_with_index { |new_applicant, index| return (index + 1) if new_applicant.id == jobseeker.id }
  end

  def current_type
    if self.deleted?
      "Deleted"
    #elsif self.is_draft?
    #  "Draft"
    elsif self.is_sent?
      "Under Approval"
    elsif !self.active?
      "Inactive"
    elsif self.end_date < Date.today
      "Expired"
    else
      "Active"
    end
  end

  def self.get_jobs(jobseeker, params)
    jobs = Job.calculate_matching_percentage(jobseeker, params[:q], params[:order]).paginate(page: params[:page])
  end

  def self.set_approved_at
    Job.approved.where(approved_at: nil).each do |job|
      job.update_column(:approved_at, job.requisitions_active.order(:approved_at).last.try(:approved_at))
    end
  end

  def calculate_probability(jobseeker)
    applicants_probability = {}

    applicants = Jobseeker.calculate_matching_percentage(self, {id_in: (JobApplication.where(job_id: self.id).pluck(:jobseeker_id) << jobseeker.id)}, 0, 100, "matching_percentage")

    index = applicants.size - 1
    statistical_rank = applicants.size
    last_matching_percetnage = 0
    count_elements = 0

    applicants.reverse_each do |applicant|
      if count_elements > 0 && applicant.matching_percentage.to_f != last_matching_percetnage
        statistical_rank = applicants.size - count_elements
      end

      probability = (1.0 / statistical_rank).to_f * applicant.matching_percentage.to_f
      applicants_probability[applicant.id] = {
          rank: statistical_rank,
          probability: probability
      }

      last_matching_percetnage = applicant.matching_percentage.to_f
      index -= 1
      count_elements += 1
    end
    applicants_probability[jobseeker.id]
  end

  def applicants_with_matching_percentage
    Jobseeker.calculate_matching_percentage(self, {id_in: (self.applicants.map(&:id) << -1)}, 0, 100, "matching_percentage")
  end

  # ranges array .. [[0,50], [50,70], [70,100]]
  def group_applicants_by_matching_percentage_range ranges
    grouped_applicants_count = {}
    applicants_with_mp = self.applicants_with_matching_percentage

    ranges.each do |range|
      # This line send queries depend on number of ranges (3 queries)
      # grouped_applicants_count[range] = applicants_with_mp.where("final_jobseekers.matching_percentage >= ? AND final_jobseekers.matching_percentage < ?", range[0], range[1]).size
      # This line in rails level
      grouped_applicants_count[range] = applicants_with_mp.select{|applicant| applicant.matching_percentage >= range[0] && applicant.matching_percentage < range[1] }.size
    end
    grouped_applicants_count
  end

  def frontend_path saudi_change_addition=0
    "#{self.country.try(:name).try(:parameterize)}/jobs/#{self.city.try(:name).try(:parameterize)}/#{self.sector.try(:name).try(:parameterize)}/#{self.title.try(:parameterize)}-#{self.id + saudi_change_addition}"
  end

  def get_average_salary
    self.salary_range.present? ? self.salary_range.get_average_salary : 0
  end

  def grade
    self.position.try(:grade)
  end



  # Export applicants to csv
  def export_applicants_csv
    CSV.generate({}) do |csv|
      first_row = ["#","Ref ID", "Name", "Email", "Mobile", "Position", "Company Name", "Sector", "Country", "City", "Age", "IELT Score", "TOEFL Score", "Highest Education","Master Score", "Bachelor Score", "Years Of Exp", "Current Salary (SAR)", "Nationality", "Gender", "University", "Field of study", "Application Status","Top 3 Skills"]
      csv << first_row

      self.applicants.matched_criteria_graduate_program.each_with_index do |sel_applicant, sel_index|
        skills_list = "";
        sel_applicant.jobseeker_skills.first(3).each_with_index  do |sel_skill, sel_skill_index|
          skills_list << "#{sel_skill.skill.name}, "
      end

          row = [
            sel_index + 1,
            sel_applicant.user.id,
            "#{sel_applicant.user.first_name} #{sel_applicant.user.last_name}",
            sel_applicant.user.email,
            sel_applicant.mobile_phone,
            (sel_applicant.jobseeker_experiences.length > 0) ? sel_applicant.jobseeker_experiences.last.position: sel_applicant.preferred_position,
            (sel_applicant.jobseeker_experiences.length > 0) ? sel_applicant.jobseeker_experiences.last.company_name : '',
            sel_applicant.sector.name,
            sel_applicant.user.country.name,
            sel_applicant.user.city.name,
            ((Time.zone.now - sel_applicant.user.birthday.to_time) / 1.year.seconds).floor,
            sel_applicant.jobseeker_graduate_program.ielts_score,
            sel_applicant.jobseeker_graduate_program.toefl_score,
            (!sel_applicant.jobseeker_graduate_program.master_gpa.nil?)? "Masters" : "Bachelors",
            sel_applicant.jobseeker_graduate_program.master_gpa,
            sel_applicant.jobseeker_graduate_program.bachelor_gpa,
            sel_applicant.years_of_experience,
            sel_applicant.current_salary,
            sel_applicant.nationality.name,
            (sel_applicant.user.gender == 1) ? "Male" : 'Female',
            sel_applicant.jobseeker_educations.last.school,
            sel_applicant.jobseeker_educations.last.field_of_study,
            JobApplication.graduate_program.where(jobseeker_id: sel_applicant.id).last.job_application_status.status,
            skills_list
        ]
        csv << row

      end
    end
  end


  # Export graduate program junk applicants to csv
  def export_applicants_csv_gp_junk
    CSV.generate({}) do |csv|
      first_row = ["#","Ref ID", "Name", "Email", "Mobile", "Position", "Company Name", "Sector", "Country", "City", "Age", "IELT Score", "TOEFL Score", "Highest Education","Master Score", "Bachelor Score", "Years Of Exp", "Current Salary (SAR)", "Nationality", "Gender", "University", "Field of study", "Application Status","Top 3 Skills"]
      csv << first_row
      Jobseeker.not_matched_criteria_graduate_program.each_with_index do |sel_applicant, sel_index|
        skills_list = "";
        sel_applicant.jobseeker_skills.first(3).each_with_index  do |sel_skill, sel_skill_index|
          skills_list << "#{sel_skill.skill.name}, "
        end

        row = [
            sel_index + 1,
            sel_applicant.user.id,
            "#{sel_applicant.user.first_name} #{sel_applicant.user.last_name}",
            sel_applicant.user.email,
            sel_applicant.mobile_phone,
            (sel_applicant.jobseeker_experiences.length > 0) ? sel_applicant.jobseeker_experiences.last.position: sel_applicant.preferred_position,
            (sel_applicant.jobseeker_experiences.length > 0) ? sel_applicant.jobseeker_experiences.last.company_name : '',
            sel_applicant.sector.name,
            sel_applicant.user.country.name,
            sel_applicant.user.city.name,
            ((Time.zone.now - sel_applicant.user.birthday.to_time) / 1.year.seconds).floor,
            sel_applicant.jobseeker_graduate_program.ielts_score,
            sel_applicant.jobseeker_graduate_program.toefl_score,
            (!sel_applicant.jobseeker_graduate_program.master_gpa.nil?)? "Masters" : "Bachelors",
            sel_applicant.jobseeker_graduate_program.master_gpa,
            sel_applicant.jobseeker_graduate_program.bachelor_gpa,
            sel_applicant.years_of_experience,
            sel_applicant.current_salary,
            sel_applicant.nationality.name,
            (sel_applicant.user.gender == 1) ? "Male" : 'Female',
            sel_applicant.jobseeker_educations.last.try(:school),
            sel_applicant.jobseeker_educations.last.try(:field_of_study),
            "Junk",
            skills_list
        ]
        csv << row

      end
    end
  end

  def has_internal_applications
    self.job_applications.where("employment_type = 'internal'").count > 0
  end

  def has_external_applications
     self.job_applications.where("employment_type = 'external'").count > 0
  end

  # handle_asynchronously :set_suggested_candidates, queue: 'save_suggested_candidates'
  protected
  def init
    @probability_success = 50
  end

  def end_date_is_after_start_date
    return if end_date.blank? || start_date.blank?

    if start_date < Date.today
      errors.add(:start_date, "cannot be before the today")
    end
    if end_date < start_date
      errors.add(:end_date, "cannot be before the start date")
    end
  end

  def experience_from_is_less_experience_to
    return if experience_from.blank? || experience_to.blank?

    if experience_from > experience_to
      errors.add(:experience_to, "cannot be less than the experience from")
    end
  end

  def join_date_after_today
    return if join_date.blank?

    if join_date < Date.today
      errors.add(:join_date, "cannot be before the today")
    end
  end


  def position_oracle_id
    return if self.try(:position).try(:oracle_id)
    errors.add(:invalid_position_id, "position_oracle_id_empty")
  end
end
