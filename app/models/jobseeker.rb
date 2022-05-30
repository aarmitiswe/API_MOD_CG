require 'wicked_pdf'
require 'wicked_pdf/pdf_helper'

class Jobseeker < ActiveRecord::Base
  include Pagination
  include DocumentNationalityIDUpload
  include SearchParams
  include SuggestedCandidates
  include RegisterationConcern
  include WickedPdf::PdfHelper

  COMPLETE_STEP = 4
  SEMI_COMPLETE_STEP = 3

  belongs_to :user
  # Note: Update_only is necessary URL: http://eewang.github.io/blog/2013/11/04/how-to-manage-complex-association-with-nested-attributes-in-rails/
  accepts_nested_attributes_for :user, update_only: true
  belongs_to :job_education
  belongs_to :job_category
  belongs_to :job_experience_level
  belongs_to :sector
  belongs_to :functional_area
  belongs_to :job_type
  belongs_to :nationality, class_name: Country, foreign_key: 'nationality_id'
  belongs_to :current_country, class_name: Country, foreign_key: 'current_country_id'
  belongs_to :current_city, class_name: City, foreign_key: 'current_city_id'
  belongs_to :driving_license_country, class_name: Country, foreign_key: 'driving_license_country_id'
  has_many :jobseeker_experiences, -> { order(from: :desc) }, inverse_of: :jobseeker, dependent: :destroy
  accepts_nested_attributes_for :jobseeker_experiences, allow_destroy: true
  has_many :jobseeker_educations, -> { order(from: :desc) }, dependent: :destroy
  accepts_nested_attributes_for :jobseeker_educations, allow_destroy: true
  has_many :jobseeker_resumes, -> { active }, dependent: :destroy
  accepts_nested_attributes_for :jobseeker_resumes, allow_destroy: true
  has_many :jobseeker_coverletters, -> { active }, dependent: :destroy
  accepts_nested_attributes_for :jobseeker_coverletters, allow_destroy: true
  has_many :jobseeker_skills, dependent: :destroy
  has_many :skills, through: :jobseeker_skills
  # accepts_nested_attributes_for :jobseeker_skills
  has_many :jobseeker_profile_views, dependent: :destroy
  has_many :jobseeker_certificates, -> { order(from: :desc) }, dependent: :destroy
  # Tags
  has_many :jobseeker_tags, dependent: :destroy
  has_many :tags, through: :jobseeker_tags
  accepts_nested_attributes_for :tags
  # Languages
  has_many :jobseeker_languages, dependent: :destroy
  has_many :languages, through: :jobseeker_languages
  accepts_nested_attributes_for :languages
  # Jobs
  has_many :saved_jobs, dependent: :destroy
  has_many :jobs, through: :saved_jobs
  # Saved search
  has_many :saved_job_searches, dependent: :destroy
  # companies followed
  has_many :company_followers, dependent: :destroy
  has_many :followed_companies, through: :company_followers, source: :company
  # Job Application
  has_many :job_applications, dependent: :destroy
  accepts_nested_attributes_for :job_applications
  has_many :applied_jobs, through: :job_applications, source: :job

  # Career Fair Application
  has_many :career_fair_applications, dependent: :destroy
  accepts_nested_attributes_for :career_fair_applications
  has_many :applied_career_fairs, through: :career_fair_applications, source: :career_fair

  # Visa Status
  belongs_to :visa_status
  has_one :notification, through: :user
  # Packages
  has_many :jobseeker_package_broadcasts, dependent: :destroy
  has_many :package_broadcasts, through: :jobseeker_package_broadcasts
  # broadcast_companies
  has_many :jobseeker_company_broadcasts, dependent: :destroy
  has_many :success_company_broadcasts, -> { where(status: 'success') }, class_name: 'JobseekerCompanyBroadcast'
  # has_many :broadcasted_companies, through: :success_company_broadcasts, class_name: 'Company', source: :company
  has_many :broadcasted_companies, through: :success_company_broadcasts, source: :company

  has_many :ratings, dependent: :destroy
  has_many :suggested_candidates, dependent: :destroy
  has_many :invited_jobseekers, dependent: :destroy
  has_many :jobseeker_folders, dependent: :destroy

  # HashTag
  # has_many :jobseeker_hash_tags, dependent: :destroy, inverse_of: :jobseeker
  has_many :jobseeker_hash_tags, dependent: :destroy
  # accepts_nested_attributes_for :jobseeker_hash_tags, allow_destroy: true
  has_many :hash_tags, through: :jobseeker_hash_tags
  # accepts_nested_attributes_for :hash_tags, allow_destroy: true

  has_one :jobseeker_graduate_program, inverse_of: :jobseeker, dependent: :destroy
  accepts_nested_attributes_for :jobseeker_graduate_program, allow_destroy: true

  has_many :bank_accounts, dependent: :destroy
  accepts_nested_attributes_for :bank_accounts, allow_destroy: true
  has_many :medical_insurances, dependent: :destroy
  accepts_nested_attributes_for :medical_insurances, allow_destroy: true
  has_many :jobseeker_on_board_documents, dependent: :destroy
  accepts_nested_attributes_for :jobseeker_on_board_documents, allow_destroy: true

  # After Update
  before_update :set_values_range_ids
  before_save :set_jobseeker_type
  #after_update :set_jobseeker_graduate_program

  validates_uniqueness_of  :nationality_id_number, case_sensitive: false, allow_blank: true
  validates_uniqueness_of  :visa_code, case_sensitive: false, allow_blank: true
  validates_uniqueness_of  :id_number, case_sensitive: false, allow_blank: true


  def destroy_or_complete
    transaction_include_any_action?([:destroy]) || self.complete_step == COMPLETE_STEP
  end

  scope :grouped_by_job_education, -> (job) { where(id: job.job_applications.pluck(:jobseeker_id)).group(:job_education_id).count }
  scope :grouped_by_sector, -> (job) { where(id: job.job_applications.pluck(:jobseeker_id)).group(:sector_id).count }
  scope :grouped_by_country, -> (job) { joins(:user).where(id: job.job_applications.pluck(:jobseeker_id)).group("users.country_id").count }
  scope :grouped_by_gender, -> (job) { joins(:user).where(id: job.job_applications.pluck(:jobseeker_id)).group("users.gender").count }
  scope :grouped_by_nationality, -> (job) { joins(:user).where(id: job.job_applications.pluck(:jobseeker_id)).group("jobseekers.nationality_id").count }

  scope :req_grouped_by_job_education, -> (job, applied_jobseeker_ids) { where(id: job.job_applications.where(jobseeker_id: applied_jobseeker_ids).pluck(:jobseeker_id)).group(:job_education_id).count }
  scope :req_grouped_by_sector, -> (job, applied_jobseeker_ids) { where(id: job.job_applications.where(jobseeker_id: applied_jobseeker_ids).pluck(:jobseeker_id)).group(:sector_id).count }
  scope :req_grouped_by_country, -> (job, applied_jobseeker_ids) { joins(:user).where(id: job.job_applications.where(jobseeker_id: applied_jobseeker_ids).pluck(:jobseeker_id)).group("users.country_id").count }
  scope :req_grouped_by_gender, -> (job, applied_jobseeker_ids) { joins(:user).where(id: job.job_applications.where(jobseeker_id: applied_jobseeker_ids).pluck(:jobseeker_id)).group("users.gender").count }
  scope :req_grouped_by_nationality, -> (job, applied_jobseeker_ids) { joins(:user).where(id: job.job_applications.where(jobseeker_id: applied_jobseeker_ids).pluck(:jobseeker_id)).group("jobseekers.nationality_id").count }

  scope :gender, -> (gender_id) { joins(:user).where('users.gender = ?', gender_id)}
  scope :age, -> (min_age, max_age) { joins(:user).where('users.birthday >= ? AND users.birthday <= ?', Date.today - max_age.years, Date.today - min_age.years)}

  scope :military, -> { where(candidate_type: 'military') }
  scope :civilian, -> { where(candidate_type: 'civilian') }
  scope :contractual, -> { where(candidate_type: 'contractual') }
  scope :order_desc, -> { order(id: :desc) }
  attr_accessor :probability

  # Group followers of company by country
  # Two join to group by country_id in user table (22 ms)
  scope :get_followers_of_company_group_by_country, -> (company) {
    joins("LEFT JOIN company_followers ON company_followers.jobseeker_id = jobseekers.id LEFT JOIN users ON users.id = jobseekers.user_id")
        .where("company_followers.company_id = ?", company.id)
        .group("users.country_id").count
  }



  # Group followers of company by nationality
  # Two join to group by nationality_id in user table (22 ms)
  scope :get_followers_of_company_group_by_nationality, -> (company) {
    joins("LEFT JOIN company_followers ON company_followers.jobseeker_id = jobseekers.id LEFT JOIN users ON users.id = jobseekers.user_id")
        .where("company_followers.company_id = ?", company.id)
        .group("jobseekers.nationality_id").count
  }

  scope :male, -> { where(user_id: User.male) }
  scope :female, -> { where(user_id: User.female) }

  scope :order_by_last_sign_in , -> {
    select("jobseekers.*, users.last_sign_in_at as last_sign").order("last_sign DESC")
  }

  scope :order_by_viewers, -> {
    joins("LEFT JOIN jobseeker_profile_views ON jobseeker_profile_views.jobseeker_id = jobseekers.id")
    .select("jobseekers.*, count(jobseeker_profile_views.id) as viewers")
    .group("jobseekers.id")
    .order("viewers DESC")
  }

  scope :order_by_current_salary, -> { order(:current_salary) }
  scope :order_by_expected_salary, -> { order(:expected_salary) }
  scope :order_by_years_of_experience, -> { order(:years_of_experience) }
  # This scope to order by years_experience
  # This Scope not used
  scope :order_by_years_experience_in_experiences, -> {
    joins("LEFT JOIN jobseeker_experiences ON jobseekers.id = jobseeker_experiences.jobseeker_id")
        .order(%q{MAX(COALESCE(jobseeker_experiences.to, CURRENT_TIMESTAMP)) - MIN(COALESCE(jobseeker_experiences.from, CURRENT_TIMESTAMP)) DESC})
        .group("jobseekers.id")
  }

  scope :matched_criteria_graduate_program, -> { where(complete_step: COMPLETE_STEP, id: JobseekerGraduateProgram.matched_criteria.pluck(:jobseeker_id)) }
  scope :not_matched_criteria_graduate_program, -> { where(complete_step: COMPLETE_STEP, id: JobseekerGraduateProgram.not_matched_criteria.pluck(:jobseeker_id)) }

  # Get User attributes
  ["first_name", "last_name", "country_id", "city_id", "birthday", "gender"].each do |attr_name|
    define_method("user_#{attr_name}") { self.user.send(attr_name) }
  end

  JOBSEEKER_ATTRIBUTE_PER_WEIGHTS = {
      sector_id: 8,
      functional_area_id: 8,
      current_country_id: 8,
      current_city_id: 4,
      job_experience_level_id: 4,
      years_of_experience: 4,
      job_type_id: 2,
      current_salary: 4,
      expected_salary: 3,
      nationality_id: 6,
      languages: 2,
      marital_status: 2,
      visa_status_id: 2,
      notice_period_in_month: 2,
      summary: 4
  }

  USER_ATTRIBUTE_PER_WEIGHTS = {
      birthday: 2,
      gender: 2,
      video_content_type: 3
  }

  ASSOCIATED_OBJECT_PER_WEIGHTS = {
      jobseeker_educations: 4,
      jobseeker_experiences: 6,
      jobseeker_skills: 4,
      jobseeker_tags: 2,
      jobseeker_resumes: 12
  }

  ALLOW_BLANK = {
      driving_license_country_id: 2
  }

  def age
    self.user.birthday.present? ? (Date.today - self.user.birthday).to_i / 365 : 0
  end

  def first_name
    self.user.first_name
  end

  def middle_name
    self.user.middle_name
  end

  def last_name
    self.user.last_name
  end

  def full_name
    self.user.full_name
  end

  def email
    self.user.email
  end

  def birthday
    self.user.birthday
  end

  def gender
    self.user.gender || 0
  end

  def has_driving_license
    self.driving_license_country_id.present?
  end

  def join_date
    self.notice_period_in_month && self.notice_period_in_month > 0 ? Date.today + self.notice_period_in_month.month : Date.yesterday
  end

  def current_company
    self.jobseeker_experiences.where(to: nil).first
  end

  def avatar
    self.user.avatar
  end

  def video
    self.user.video
  end

  def video_screenshot
    self.user.video_screenshot
  end

  def last_active
    self.user.last_active || self.user.last_sign_in_at
  end

  # {
  #   "InputParameters": {
  #     "P_FIRST_NAME": "Majed",
  #     "P_FATHER_NAME": "Ahmed",
  #     "P_GRANDFATHER_NAME": "Mohammed",
  #     "P_POSITION_ID": "2061",
  #     "P_GRADE": "Level0",
  #     "P_EFFECTIVE_START_DATE": "21/09/2021",
  #     "P_LAST_NAME": "Eldossary",
  #     "P_DATE_OF_BIRTH": "19/05/1970",
  #     "P_EMAIL_ADDRESS":"Majed.Eldossary@gmail.com",
  #     "P_NATIONAL_IDENTIFIER": "123456",
  #     "P_SEX": "M",
  #     "P_TOWN_OF_BIRTH": "Riyadh",
  #     "P_COUNTRY_OF_BIRTH": "SA",
  #     "P_NATIONALITY": "PQH_SA",
  #     "P_RELIGION": "MUSLIM"
  #   }
  # }
  def oracle_object
    {
      "P_FIRST_NAME" => self.first_name,
      "P_FATHER_NAME" => self.middle_name || "NA",
      "P_GRANDFATHER_NAME" => self.grandfather_name || "NA",
      "P_LAST_NAME" => self.last_name,
      "P_DATE_OF_BIRTH" => self.birthday.try(:strftime, "%d/%m/%Y") || "NA",
      "P_EMAIL_ADDRESS" => self.email,
      "P_NATIONAL_IDENTIFIER" => self.id_number,
      "P_SEX" => self.user.gender_char || "NA",
      "P_TOWN_OF_BIRTH" => self.user.city.try(:name) || self.current_city.try(:name) || "NA",
      "P_COUNTRY_OF_BIRTH" => self.user.country.try(:iso) || self.current_country.try(:iso) || "NA",
      "P_NATIONALITY" => self.nationality.try(:lookup_nationality) || "NA",
      "P_RELIGION" => self.religion.try(:upcase) || "NA",
      "P_EFFECTIVE_START_DATE" => self.effective_start_date.try(:strftime, "%d/%m/%Y") || "NA"
    }
  end



  def complete_profile_percentage
    percentage = 0
    Jobseeker::JOBSEEKER_ATTRIBUTE_PER_WEIGHTS.each do |attr, weight|
      percentage += weight unless self.send(attr).blank?
    end

    Jobseeker::USER_ATTRIBUTE_PER_WEIGHTS.each do |attr, weight|
      percentage += weight unless self.user.send(attr).blank?
    end

    Jobseeker::ASSOCIATED_OBJECT_PER_WEIGHTS.each do |attr, weight|
      percentage += weight unless self.send(attr).blank?
    end

    percentage += Jobseeker::ALLOW_BLANK.values.inject(&:+)

    percentage
  end

  def applied_jobs_by_country
    percent_of_applications(self.applied_jobs.by_country).sort_by { |_k, v| v }.reverse
  end

  def applied_jobs_by_sector
    percent_of_applications(self.applied_jobs.by_sector).sort_by { |_k, v| v }.reverse
  end

  def default_resume
    active_resume = {}
    self.jobseeker_resumes.each do |sel_resume|
      active_resume = sel_resume
      if sel_resume.default
        break
      end
    end
    active_resume.try(:document).try(:url)
  end

  def current_experience
    self.jobseeker_experiences.order(to: :desc).first
  end

  def current_position
    self.current_experience.try(:position)
  end

  def user_city
    self.user.city
  end

  def user_country
    self.user.country
  end

  def get_experience_dates
    start_dates = self.jobseeker_experiences.map(&:from)
    smallest_start_date = start_dates.include?(nil) ? Date.today : start_dates.min
    end_dates = self.jobseeker_experiences.map(&:to)
    largest_end_date = end_dates.include?(nil) ? Date.today : end_dates.max
    {
        min_start_date: smallest_start_date,
        max_end_date: largest_end_date
    }
  end

  def min_experience_date
    start_dates = self.jobseeker_experiences.map(&:from)
    start_dates.include?(nil) ? Date.today : start_dates.min
  end


  def max_experience_date
    end_dates = self.jobseeker_experiences.map(&:to)
    end_dates.include?(nil) ? Date.today : end_dates.max
  end

  def certificate_ids
    certificate_ids = self.jobseeker_certificates.where.not(certificate_id: nil).pluck(:certificate_id)
    certificate_ids.blank? ? [-1] : certificate_ids
  end

  def expected_salary_range_ids
    salary_ranges = SalaryRange.where("salary_from <= ? AND salary_to >= ?", self.expected_salary, self.expected_salary)
    ids = salary_ranges.blank? ? "(-1, -1)" : "(#{salary_ranges.map(&:id).join(',')})"
    ids
  end

  def has_common_skills_with_job job_id
    !(Job.find_by_id(job_id).skill_ids & self.skill_ids).blank?
  end

  def job_ids_has_common_skills
    job_ids = JobSkill.where(skill_id: self.skill_ids).pluck(:job_id).uniq
    job_ids.blank? ? [-1] : job_ids
  end

  def job_ids_has_common_languages
    job_ids = JobLanguage.where(language_id: self.language_ids).pluck(:job_id).uniq
    job_ids.blank? ? [-1] : job_ids
  end

  def job_ids_has_common_certificates
    job_ids = JobCertificate.where(certificate_id: self.certificate_ids).pluck(:job_id).uniq
    job_ids.blank? ? [-1] : job_ids
  end

  def job_ids_in_same_geo_group
    job_ids = JobCountry.where(country_id: self.nationality_id).pluck(:job_id).uniq
    # geo_group_ids = CountryGeoGroup.where(country_id: self.nationality_id).pluck(:geo_group_id).uniq
    # job_ids = JobGeoGroup.where(geo_group_id: geo_group_ids).pluck(:job_id).uniq
    job_ids.blank? ? [-1] : job_ids
  end

  def job_ids_in_same_geo_countries
    job_ids = JobCountry.where(country_id: self.nationality_id).pluck(:job_id).uniq
    job_ids.blank? ? [-1] : job_ids
  end

  def positions
    self.jobseeker_experiences.pluck(:position) << 'a'
  end

  def age_group
    AgeGroup.where("min_age <= ? AND max_age >= ?", self.age, self.age).first
  end

  def age_group_ids
    AgeGroup.where("? BETWEEN min_age AND max_age", self.age).pluck(:id) << -1
  end

  def get_job_application_for_job job_id
    return nil if job_id.nil?
    JobApplication.find_by(job_id: job_id, jobseeker_id: self.id)
  end


  def get_job_application_extra_doc_url job_id
    return nil if job_id.nil?
    JobApplication.find_by(job_id: job_id, jobseeker_id: self.id).try(:extra_document).try(:url)
  end

  def get_invited_for_job job_id
    return nil if job_id.nil?
    InvitedJobseeker.find_by(job_id: job_id, jobseeker_id: self.id)
  end

  # This one has_one skill
  def self.has_one_skills skills_names
    Jobseeker.joins(:skills).where("skills.name = ANY(ARRAY[?]::varchar[])", skills_names)
  end

  def status_style
    s = if self.is_completed? && self.user.active?
          "active-complete"
        elsif self.user.active?
          "active-non-complete"
        else
          "inactive"
        end
    s
  end

  def num_remaining_credits
    self.jobseeker_package_broadcasts.sum(:num_credits) - self.jobseeker_company_broadcasts.success.count
  end

  def has_enough_credit?
    self.num_remaining_credits > 0
  end

  def self.to_csv exported_data
    attributes = %w{id full_name email mobile_phone home_phone}

    CSV.generate(headers: true) do |csv|
      csv << attributes

      exported_data.each do |user|
        csv << attributes.map{ |attr| user.send(attr) }
      end
    end
  end

  def is_completed?
    complete_step == COMPLETE_STEP
  end

  def set_values_range_ids
    self.experience_range_id = ExperienceRange.where("experience_from <= ? AND experience_to >= ?", self.years_of_experience, self.years_of_experience).first.try(:id) if self.years_of_experience
    self.current_salary_range_id = SalaryRange.where("salary_from <= ? AND salary_to >= ?", self.current_salary, self.current_salary).first.try(:id) if self.current_salary
    self.expected_salary_range_id = SalaryRange.where("salary_from <= ? AND salary_to >= ?", self.expected_salary, self.expected_salary).first.try(:id) if self.expected_salary
  end

  def set_jobseeker_type
    self.jobseeker_type = "normal" if self.jobseeker_type.blank?
  end

  def notice_period_as_words
    words = if self.notice_period_in_month.present? && self.notice_period_in_month > 0
              self.notice_period_in_month > 1 ? "#{self.notice_period_in_month} Months" : "#{self.notice_period_in_month} Month"
            else
              "Less than 1 Month"
            end
    words
  end

  def nationality_id_number
    self.read_attribute(:nationality_id_number) || self.read_attribute(:id_number)
  end

  def highest_bachelor_gpa
    bachelor_degree = JobEducation.find_by_level("Bachelor Degree")
    self.jobseeker_educations.order(grade: :asc).where(job_education_id: bachelor_degree.id).last.try(:grade).try(:to_f)
  end

  def highest_master_gpa
    master_degree = JobEducation.find_by_level("Masters Degree")
    self.jobseeker_educations.order(grade: :asc).where(job_education_id: master_degree.id).last.try(:grade).try(:to_f)
  end

  def set_jobseeker_graduate_program
    self.jobseeker_graduate_program.update(nationality_id: self.nationality_id, age: self.age,
                                           bachelor_gpa: self.highest_bachelor_gpa,
                                           master_gpa: self.highest_master_gpa) if self.jobseeker_graduate_program
  end

  def profile_path_for_employer
    "#{Rails.application.secrets["FRONTEND"]}/employer/candidate/#{self.user.id}/profile"
  end

  # TODO: Remove this method
  def profile_as_pdf

    # @jobseeker = jobseeker
    # template_str = File.read("#{Rails.root.to_s}/app/views/api/v1/jobseekers/display_profile_pdf.html.erb")
    # template = ERB.new(template_str)
    # template.run
    # template.result
    #
    # # pdf = WickedPdf.new.pdf_from_html_file("#{Rails.root.to_s}/app/views/api/v1/jobseekers/display_profile_pdf.html.erb")
    # pdf = WickedPdf.new.pdf_from_string(
    #     render_to_string("#{Rails.root.to_s}/app/views/api/v1/jobseekers/display_profile_pdf.html.erb", layout: 'pdf')
    # )

    # # template_str = File.read("#{Rails.root.to_s}/app/views/api/v1/jobseekers/display_profile_pdf.html.erb")
    # # template = ERB.new(template_str)
    @jobseeker = self
    # w  = WickedPdf.new
    #
    # # w.pdf_from_html_file("#{Rails.root.to_s}/app/views/api/v1/jobseekers/display_profile_pdf.html.erb")
    # w.pdf_from_string(render_to_string(template: "#{Rails.root.to_s}/app/views/api/v1/jobseekers/display_profile_pdf.html.erb", layout: 'pdf'))

    # instantiate an ActionView object
    view = ActionView::Base.new(ActionController::Base.view_paths, {})
    # include helpers and routes
    view.extend(ApplicationHelper)
    view.extend(Rails.application.routes.url_helpers)
    pdf = WickedPdf.new.pdf_from_string(
        # view.render(
        #     {
        #         pdf: "jobseeker_resume",
        #         template: "api/v1/jobseekers/display_profile_pdf.html.erb",
        #         locals: { '@jobseeker' => @jobseeker, jobseeker: @jobseeker },
        #         format: [:html],
        #         handlers: [:erb],
        #         assigns: { '@jobseeker' => @jobseeker, jobseeker: @jobseeker },
        #         layout: false
        #     }, { '@jobseeker' => @jobseeker, jobseeker: @jobseeker, assigns: { '@jobseeker' => @jobseeker, jobseeker: @jobseeker } }
        # )
        render_to_string(template: "api/v1/jobseekers/display_profile_pdf.html.erb")
    )
    save_path = Rails.root.join('pdfs','filename.pdf')
    File.open(save_path, 'wb') do |file|
      file << pdf
    end
  end

  def get_profile_as_pdf
    jobseeker_controller = Api::V1::JobseekersController.new
    pdf = jobseeker_controller.save_as_pdf self
    pdf
  end

  def average_rating
    (self.ratings.count > 0) ? (self.ratings.sum(:rate) / self.ratings.count) : 0.0
  end

  # TODO: Remove this method
  def trial_pdf
    # @jobseeker = self
    #
    # pdf = WickedPdf.new.pdf_from_string(
    #     render_to_string('api/v1/jobseekers/display_profile_pdf.html.erb', layout: false)
    # )
    # pdf
    #
    jobseeker_controller = Api::V1::JobseekersController.new
    pdf = jobseeker_controller.save_as_pdf self
    pdf
  end

  # This method to update complete_step attribute
  # TODO: Remove this method from ATS
  def self.update_complete_step_column
    # Non-Active User:
    non_active = Jobseeker.joins(:user).where("users.active = ? OR users.deleted = ?", false, true)
    non_active.update_all(complete_step: 1)
    nil_country_or_city = Jobseeker.joins(:user).where("jobseekers.complete_step IS NULL AND (users.country_id IS NULL OR users.country_id = 0 OR users.city_id IS NULL OR users.city_id = 0)")
    nil_country_or_city.update_all(complete_step: 1)

    first_step_jobseekers = Jobseeker.where(complete_step: nil).where("sector_id IS NULL OR sector_id = 0 OR functional_area_id IS NULL OR functional_area_id = 0 OR job_experience_level_id IS NULL OR job_experience_level_id = 0 OR years_of_experience IS NULL OR current_salary IS NULL")
    first_step_jobseekers.update_all(complete_step: 1)

    second_step_jobseekers = Jobseeker.joins(:jobseeker_languages).group("jobseekers.id").having("COUNT(jobseeker_languages.language_id) = 0").where(complete_step: nil)
    second_step_jobseekers.update_all(complete_step: 2)
    second_step_jobseekers = Jobseeker.where(complete_step: nil).where("job_education_id IS NULL OR job_education_id = 0 OR mobile_phone IS NULL OR mobile_phone = '' OR marital_status IS NULL OR marital_status = '' OR visa_status_id IS NULL OR visa_status_id = 0")
    second_step_jobseekers.update_all(complete_step: 2)

    completed_jobseekers  = Jobseeker.where(complete_step: nil, profile_completed: true)
    completed_jobseekers.update_all(complete_step: 4)
    completed_jobseekers  = Jobseeker.joins(:user).where("jobseekers.complete_step IS NULL AND (users.avatar_file_size IS NOT NULL OR users.video_file_size IS NOT NULL)")
    completed_jobseekers.update_all(complete_step: 4)

    third_step_jobseekers = Jobseeker.where(complete_step: nil).where(profile_completed: false)
    third_step_jobseekers.update_all(complete_step: 3)
  end

  private
    def percent_of_applications(job_applications)
      total_count = self.job_applications.count
      job_applications.each do |k, v|
        percentage = ((v.to_f / total_count) * 100).floor
        job_applications[k] = (percentage == 0) ? 1 : percentage
      end
      return job_applications
    end
end
