require 'tilt/erb'

class JobApplication < ActiveRecord::Base
  include Pagination
  include SendInvitation

  belongs_to :jobseeker
  belongs_to :job
  belongs_to :job_application_status
  belongs_to :jobseeker_coverletter
  belongs_to :jobseeker_resume
  belongs_to :employer, foreign_key: :user_id, class_name: User

  has_one :candidate_information_document,  dependent: :destroy
  belongs_to :security_clearance_result_document,  dependent: :destroy

  has_many :job_application_status_changes, dependent: :destroy
  has_many :offer_letters, through: :job_application_status_changes
  has_many :interviews, through: :job_application_status_changes
  has_many :interview_committee_members, through: :interviews
  has_many :calls, through: :interviews
  has_many :assessments, through: :job_application_status_changes
  has_many :notes, dependent: :destroy
  has_many :evaluation_submits, dependent: :destroy

  has_many :evaluation_submit_requisitions, dependent: :destroy

  has_many :offer_requisitions, dependent: :destroy
  has_many :salary_analyses, -> { order(level: :desc) }, dependent: :destroy
  has_many :offer_analyses, -> { order(level: :desc) }, dependent: :destroy

  has_many :boarding_forms, dependent: :destroy
  has_many :boarding_requisitions, dependent: :destroy

  has_attached_file :extra_document, dependent: :destroy

  validates_attachment_content_type :extra_document, content_type: [
      "application/pdf", "application/msword", "application/vnd.ms-office", "text/plain", "application/xls",
      "application/xlsx", "application/doc", "application/docx", "application/ppt", "application/pptx",
      "image/jpg", "image/jpeg", "image/png", "image/gif", "image/bmp",
      "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
  ]

  validates_presence_of :jobseeker, :job, :job_application_status
  validates :job_id, uniqueness: {scope: :jobseeker_id}

  before_validation :set_job_application_status, on: :create
  before_save :before_save_doc

  def before_save_doc
    if self.extra_document.present?
      tempfile = self.extra_document.queued_for_write[:original]
      unless tempfile.nil?
        extension = File.extname(tempfile.original_filename)
        if !extension || extension == ''
          mime = tempfile.content_type
          ext = Rack::Mime::MIME_TYPES.invert[mime]
          # Rails.application.debugger "#{tempfile.original_filename}#{ext}"
          self.extra_document.instance_write :file_name, "#{tempfile.original_filename}#{ext}"
        end
      end
    end
    true
  end

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
  scope :assessment_security_clearance_job_offer, -> { where(job_application_status_id: JobApplicationStatus.where(status: [JobApplicationStatus::KEYWORDS["Assessment"], JobApplicationStatus::KEYWORDS["SecurityClearance"], JobApplicationStatus::KEYWORDS["JobOffer"]]).pluck(:id)) }
  scope :in_progress, -> { where.not(job_application_status_id: JobApplicationStatus.where(status: [JobApplicationStatus::KEYWORDS["Successful"], JobApplicationStatus::KEYWORDS["Unsuccessful"]]).pluck(:id)) }
  scope :matched_criteria_graduate_program, -> (job) { where(jobseeker_id: Jobseeker.where(id: job.job_applications.pluck(:jobseeker_id)).matched_criteria_graduate_program.pluck(:id)) }
  scope :for_company, -> (company) { where(job_id: company.job_ids) }
  scope :graduate_program, -> { where(job_id: Job.find_by_title('graduate_program').try(:id)) }

  scope :internal, -> { where(job_id: Job.internal.pluck(:id)) }
  scope :external, -> { where(job_id: Job.external.pluck(:id)) }
  scope :both, -> { where(job_id: Job.both.pluck(:id)) }
  scope :military, -> { where(jobseeker_id: Jobseeker.military.pluck(:id)) }
  scope :civilian, -> { where(jobseeker_id: Jobseeker.civilian.pluck(:id)) }
  scope :contractual, -> { where(jobseeker_id: Jobseeker.contractual.pluck(:id)) }
  scope :not_deleted, -> { where(deleted: false) }

  # Of Company Groups
  scope :get_applications_of_company_group_by_jobseeker_country, -> (company) {
    joins("LEFT JOIN jobseekers ON job_applications.jobseeker_id = jobseekers.id")
    .where("job_applications.job_id IN (?)", company.job_ids)
    .group("jobseekers.current_country_id").count
  }

  scope :get_applications_of_company_group_by_country, -> (company) {
    joins("LEFT JOIN jobseekers ON job_applications.jobseeker_id = jobseekers.id")
        .joins("LEFT JOIN users ON jobseekers.user_id = users.id")
        .where("job_applications.job_id IN (?)", company.job_ids)
        .group("users.country_id").count
  }

  scope :get_applications_of_company_group_by_nationality, -> (company) {
    joins("LEFT JOIN jobseekers ON job_applications.jobseeker_id = jobseekers.id")
    .where("job_applications.job_id IN (?)", company.job_ids)
    .group("jobseekers.nationality_id").count
  }

  scope :get_applications_of_company_group_by_sector, -> (company) {
    joins("LEFT JOIN jobseekers ON job_applications.jobseeker_id = jobseekers.id")
    .where("job_applications.job_id IN (?)", company.job_ids)
    .group("jobseekers.sector_id").count
  }

  scope :get_applications_of_company_group_by_education, -> (company) {
    joins("LEFT JOIN jobseekers ON job_applications.jobseeker_id = jobseekers.id")
    .where("job_applications.job_id IN (?)", company.job_ids)
    .group("jobseekers.job_education_id").count
  }


  scope :get_applications_of_company_group_by_age_group, -> (company) {

    joins("LEFT JOIN jobseekers ON job_applications.jobseeker_id = jobseekers.id")
        .joins("LEFT JOIN users ON users.id = jobseekers.user_id")
        .where("job_applications.job_id IN (?)", company.job_ids)
        .where("users.birthday IS NOT NULL")
        .group("DATE_TRUNC('year', birthday)").count

  }

  scope :get_applications_of_company_group_by_gender, -> (company) {

    joins("LEFT JOIN jobseekers ON job_applications.jobseeker_id = jobseekers.id")
        .joins("LEFT JOIN users ON jobseekers.user_id = users.id")
        .where("job_applications.job_id IN (?)", company.job_ids)
        .group("users.gender").count
  }


  # of Job Groups

  scope :get_applications_of_job_group_by_user_country, -> (job) {
    joins("LEFT JOIN jobseekers ON job_applications.jobseeker_id = jobseekers.id")
        .joins("LEFT JOIN users ON jobseekers.user_id = users.id")
        .where("job_applications.job_id = ?", job.id)
        .group("users.country_id").count
  }

  scope :get_applications_of_job_group_by_user_city, -> (job) {
    joins("LEFT JOIN jobseekers ON job_applications.jobseeker_id = jobseekers.id")
        .joins("LEFT JOIN users ON jobseekers.user_id = users.id")
        .where("job_applications.job_id = ?", job.id)
        .group("users.city_id").count
  }

  scope :get_applications_of_job_group_by_nationality, -> (job) {
    joins("LEFT JOIN jobseekers ON job_applications.jobseeker_id = jobseekers.id")
        .where("job_applications.job_id = ?", job.id)
        .group("jobseekers.nationality_id").count
  }

  scope :get_applications_of_job_group_by_sector, -> (job) {
    joins("LEFT JOIN jobseekers ON job_applications.jobseeker_id = jobseekers.id")
        .where("job_applications.job_id = ?", job.id)
        .group("jobseekers.sector_id").count
  }

  scope :get_applications_of_job_group_by_functional_area, -> (job) {
    joins("LEFT JOIN jobseekers ON job_applications.jobseeker_id = jobseekers.id")
        .where("job_applications.job_id = ?", job.id)
        .group("jobseekers.functional_area_id").count
  }

  scope :get_applications_of_job_group_by_nationality, -> (job) {
    joins("LEFT JOIN jobseekers ON job_applications.jobseeker_id = jobseekers.id")
        .where("job_applications.job_id = ?", job.id)
        .group("jobseekers.nationality_id").count
  }

  scope :get_applications_of_job_group_by_job_eduction, -> (job) {
    joins("LEFT JOIN jobseekers ON job_applications.jobseeker_id = jobseekers.id")
        .where("job_applications.job_id = ?", job.id)
        .group("jobseekers.job_education_id").count
  }

  scope :get_applications_of_job_group_by_age_group, -> (job) {

    joins("LEFT JOIN jobseekers ON job_applications.jobseeker_id = jobseekers.id")
        .joins("LEFT JOIN users ON users.id = jobseekers.user_id")
        .where("job_applications.job_id = ?", job.id)
        .where("users.birthday IS NOT NULL")
        .group("DATE_TRUNC('year', birthday)").count

  }

  scope :get_applications_of_job_group_by_gender, -> (job) {

    joins("LEFT JOIN jobseekers ON job_applications.jobseeker_id = jobseekers.id")
        .joins("LEFT JOIN users ON users.id = jobseekers.user_id")
        .where("job_applications.job_id = ?", job.id)
        .group("users.gender").count

  }


  scope :get_applications_of_job_group_by_jobseeker_type, -> (job) {

    joins("LEFT JOIN jobseekers ON job_applications.jobseeker_id = jobseekers.id")
        .joins("LEFT JOIN users ON users.id = jobseekers.user_id")
        .where("job_applications.job_id = ?", job.id)
        .group("jobseekers.jobseeker_type").count

  }

  scope :get_applications_of_job_group_by_job_type, -> (job) {
    joins("LEFT JOIN jobseekers ON job_applications.jobseeker_id = jobseekers.id")
        .where("job_applications.job_id = ?", job.id)
        .group("jobseekers.job_type_id").count
  }

  scope :get_applications_of_job_group_by_visa_status, -> (job) {
    joins("LEFT JOIN jobseekers ON job_applications.jobseeker_id = jobseekers.id")
        .where("job_applications.job_id = ?", job.id)
        .group("jobseekers.visa_status_id").count
  }

  scope :get_applications_of_job_group_by_marital_status, -> (job) {
    joins("LEFT JOIN jobseekers ON job_applications.jobseeker_id = jobseekers.id")
        .where("job_applications.job_id = ?", job.id)
        .group("jobseekers.marital_status").count
  }

  scope :get_applications_of_job_group_by_notice_period, -> (job) {
    joins("LEFT JOIN jobseekers ON job_applications.jobseeker_id = jobseekers.id")
        .where("job_applications.job_id = ?", job.id)
        .group("jobseekers.notice_period_in_month").count
  }

  scope :get_applications_of_job_group_by_language, -> (job) {
    joins("LEFT JOIN jobseeker_languages ON job_applications.jobseeker_id = jobseeker_languages.jobseeker_id")
        .where("job_applications.job_id = ?", job.id)
        .group("jobseeker_languages.language_id").count
  }


  scope :get_applications_of_job_group_by_last_active, -> (job) {

    joins("LEFT JOIN jobseekers ON job_applications.jobseeker_id = jobseekers.id")
        .joins("LEFT JOIN users ON users.id = jobseekers.user_id")
        .where("job_applications.job_id = ?", job.id)
        .group("DATE_TRUNC('day', last_active)").count

  }

  scope :get_applications_of_job_group_by_experience_range, -> (job) {
    joins("LEFT JOIN jobseekers ON job_applications.jobseeker_id = jobseekers.id")
        .where("job_applications.job_id = ?", job.id)
        .group("jobseekers.experience_range_id").count
  }

  scope :get_applications_of_job_group_by_current_salary, -> (job) {
    joins("LEFT JOIN jobseekers ON job_applications.jobseeker_id = jobseekers.id")
        .where("job_applications.job_id = ?", job.id)
        .group("jobseekers.current_salary_range_id").count
  }

  scope :get_applications_of_job_group_by_expected_salary, -> (job) {
    joins("LEFT JOIN jobseekers ON job_applications.jobseeker_id = jobseekers.id")
        .where("job_applications.job_id = ?", job.id)
        .group("jobseekers.expected_salary_range_id").count
  }


  scope :get_applications_of_job_group_by_master_degree_grade, -> (job) {
    joins("LEFT JOIN jobseeker_educations ON job_applications.jobseeker_id = jobseeker_educations.jobseeker_id")
        .where("job_applications.job_id = ?", job.id)
        .where("jobseeker_educations.job_education_id = ?", JobEducation.find_by_level('Masters Degree').id)
        .group("jobseeker_educations.grade").count
  }


  scope :get_applications_of_job_group_by_bachelor_degree_grade, -> (job) {
    joins("LEFT JOIN jobseeker_educations ON job_applications.jobseeker_id = jobseeker_educations.jobseeker_id")
        .where("job_applications.job_id = ?", job.id)
        .where("jobseeker_educations.job_education_id = ?", JobEducation.find_by_level('Bachelor Degree').id)
        .group("jobseeker_educations.grade").count
  }

  scope :get_applications_of_job_group_by_ielts_score, -> (job) {
    joins("LEFT JOIN jobseeker_graduate_programs ON job_applications.jobseeker_id = jobseeker_graduate_programs.jobseeker_id")
        .where("job_applications.job_id = ?", job.id)
        .group("jobseeker_graduate_programs.ielts_score").count
  }

  scope :get_applications_of_job_group_by_toefl_score, -> (job) {
    joins("LEFT JOIN jobseeker_graduate_programs ON job_applications.jobseeker_id = jobseeker_graduate_programs.jobseeker_id")
        .where("job_applications.job_id = ?", job.id)
        .group("jobseeker_graduate_programs.toefl_score").count
  }

  scope :get_applications_of_job_group_by_school, -> (job, jobseeker_education_ids) {
    joins("LEFT JOIN jobseeker_educations ON job_applications.jobseeker_id = jobseeker_educations.jobseeker_id")
        .where("job_applications.job_id = ?", job.id)
        .where("jobseeker_educations.id IN (?)", jobseeker_education_ids)
        .group("jobseeker_educations.school").count
  }

  scope :get_applications_of_job_group_by_field_of_study, -> (job, jobseeker_education_ids) {
    joins("LEFT JOIN jobseeker_educations ON job_applications.jobseeker_id = jobseeker_educations.jobseeker_id")
        .where("job_applications.job_id = ?", job.id)
        .where("jobseeker_educations.id IN (?)", jobseeker_education_ids)
        .group("jobseeker_educations.field_of_study").count
  }


  attr_accessor :skip_sending
  after_save :check_and_send_notification

  # Analysis Job Applications By Date
  scope :daily, -> { where("job_applications.created_at > ?", 1.week.ago).group("DATE_TRUNC('day', job_applications.created_at)").count }
  scope :weekly, -> { where("job_applications.created_at > ?", 2.month.ago).group("DATE_TRUNC('week', job_applications.created_at)").count }
  scope :monthly, -> { where("job_applications.created_at > ?", 1.year.ago).group("TO_CHAR(DATE_TRUNC('month', job_applications.created_at), 'MON')").count }
  scope :quarterly, -> { where("job_applications.created_at > ?", Date.today.beginning_of_year).group("extract(quarter from job_applications.created_at)").count }
  scope :yearly, -> { where("job_applications.created_at > ?", 12.year.ago).group("TO_CHAR(DATE_TRUNC('year', job_applications.created_at), 'YYYY')").count }

  scope :get_applications_of_job_group_by_school, -> (job, jobseeker_education_ids) {
    joins("LEFT JOIN jobseeker_educations ON job_applications.jobseeker_id = jobseeker_educations.jobseeker_id")
        .where("job_applications.job_id = ?", job.id)
        .where("jobseeker_educations.id IN (?)", jobseeker_education_ids)
        .group("jobseeker_educations.school").count
  }

  scope :get_applications_of_job_group_by_field_of_study, -> (job, jobseeker_education_ids) {
    joins("LEFT JOIN jobseeker_educations ON job_applications.jobseeker_id = jobseeker_educations.jobseeker_id")
        .where("job_applications.job_id = ?", job.id)
        .where("jobseeker_educations.id IN (?)", jobseeker_education_ids)
        .group("jobseeker_educations.field_of_study").count
  }


  # JobApplicationStatus.all.each do |job_application_status|
  #   define_method("is_#{job_application_status.status.downcase}?") { self.job_application_status.status == job_application_status.status }
  # end
  JobApplicationStatus::KEYWORDS.keys.each do |job_application_status_value|
    define_method("is_#{job_application_status_value.downcase}?") { self.job_application_status.status == job_application_status_value }
  end



  def last_job_application_status_change
    self.job_application_status_changes.order(:created_at).last
  end

  def is_successful?
    ["hired", "successful", "completed"].include? self.job_application_status.status.downcase
  end


  def is_submitted_by_all_interviewers?
    !self.evaluation_submits.count.zero? && !self.interviews.map{|i| i.interview_committee_members.count}.sum.zero? && self.evaluation_submits.count == self.interviews.map{|i| i.interview_committee_members.count}.sum
  end

  def self.export_all_applicants
    p = Axlsx::Package.new

    p.workbook.add_worksheet(name: "Basic Worksheet") do |sheet|
      sheet.add_row ["Master Report for Applicants"]
      sheet.add_row ["ID", "Name", "Email", "Job ID", "Position Name", "Grade", 'Unit', "Section",
        "Department", "General Department", "Deputy", "Application ID", "Stage",
        "Number of days from applied date", "Employment Type", "Creator of JOB",
        "Creator of Applicant", "Approved Date of JOB", "Job Status"]

      job_applications = JobApplication.order(:created_at)

      job_applications.each do |job_application|
        #   Fill the file
        job = job_application.job
        job_status_name = job.try(:job_status).try(:status)
        position = job.position
        section = job.section
        grade = job.grade
        creator_job = job.user || job.requisitions_active.first.user

        days = (Date.today - job_application.created_at.to_date).to_i

        jobseeker = job_application.jobseeker
        user = jobseeker.user

        pending_department = 'NA'

        creator_application = job_application.job_application_status_changes.applied.last.try(:employer) || job_application.employer

        row = [user.id, user.full_name, user.email, job.id, job.title, grade.try(:name)||'NA',
          job.unit.try(:name)||"NA", job.section.try(:name) || "NA",
          job.department.try(:name) || 'NA', job.general_department.try(:name) || 'NA',
          job.deputy.try(:name) || 'NA', job_application.id,
          job_application.job_application_status.try(:status) || 'NA', days,
          job.employment_type, creator_job.try(:full_name) || 'NA',
          creator_application.try(:full_name) || 'NA', job.approved_at,
          job_status_name
        ]

        sheet.add_row row
      end
    end

    p.use_shared_strings = true
    p.serialize("#{Rails.root}/public/jobseekers-excel/all-applicants.xlsx")
  end

  def self.create_bulk jobseeker_ids, job_id, job_application_status_id, employer_id, employment_type, candidate_type, user_id
    job_applications = []
    jobseeker_ids.each do |jobseeker_id|
      jobseeker = Jobseeker.find(jobseeker_id)
      jobseeker_user = jobseeker.user
      job_application = JobApplication.new(jobseeker_id: jobseeker_id,
                                           job_id: job_id, job_application_status_id: job_application_status_id,
                                           employment_type: employment_type, candidate_type: candidate_type,
                                           user_id: user_id)
      job_application_status_change = JobApplicationStatusChange.new(jobseeker_id: jobseeker_user.id, employer_id: employer_id, job_application_status_id: job_application_status_id)
      if job_application.save
        job_application_status_change.job_application_id = job_application.id
        job_application_status_change.save
      end

      job_applications << job_application

    end

    job_applications
  end

  def get_all_documents
    document_list = []

    #Resume Document
    document_list.push({name: 'resume', url: self.jobseeker.jobseeker_resumes.last.document.url})

    #On Boarding Documents
    self.jobseeker.jobseeker_on_board_documents.each_with_index do |b_doc, b_index|
      document_list.push({name: b_doc.type_of_document, url: b_doc.document.url}) if !b_doc.document.url.blank?
    end


    #Signed Joining Document
    if self.boarding_forms.last.try(:signed_joining_document).try(:url).try(:present?)
      document_list.push({name: 'signed_joining_document', url: self.boarding_forms.last.signed_joining_document.url})
    end

    #Candidate Information Documents
    if self.candidate_information_document.try(:document).try(:url).try(:present?)
      document_list.push({name: 'national_id_iqama', url: self.candidate_information_document.document.url})
    end

    if self.candidate_information_document.try(:document_three).try(:url).try(:present?)
      document_list.push({name: 'security_clearance_form', url: self.candidate_information_document.document_three.url})
    end

    if self.candidate_information_document.try(:document_four).try(:url).try(:present?)
      document_list.push({name: 'family_id', url: self.candidate_information_document.document_four.url})
    end

    if self.candidate_information_document.try(:document_report).try(:url).try(:present?)
      document_list.push({name: 'security_clearance_report', url: self.candidate_information_document.document_report.url})
    end

    #Offer Letter
    if self.try(:offer_letters).try(:last).try(:document).try(:url).try(:present?)
      document_list.push({name: 'offer_letter', url: self.offer_letters.last.document.url})
    end

    #Assessment Documents
    self.jobseeker..assessments.each_with_index do |a_doc, a_index|
      document_list.push({name: "assessment_#{a_doc.assessment_type}", url: a_doc.document_report.url}) if !a_doc.document_report.url.blank?
    end

    # signed_joining_document boarding Form
    if self.try(:boarding_forms).try(:last).try(:signed_joining_document).try(:url).try(:present?)
      document_list.push({name: 'signed_joining_document', url: self.boarding_forms.last.signed_joining_document.url})
    end


    document_list
  end

  def get_feedback_template_values
    last_change = self.job_application_status_changes.where(job_application_status_id: self.job_application_status_id).last
    template_values = {
        JobTitle: self.job.title,
        JobId: self.job.id,
        HiringManagerName: self.job.user.full_name,
        primaryColor: Rails.application.secrets[:ATS_CSS]["colors"]["primary"],
        secondaryColor: Rails.application.secrets[:ATS_CSS]["colors"]["secondary"],
        lightBg: Rails.application.secrets[:ATS_CSS]["colors"]["lightBg"],
        borderColor: Rails.application.secrets[:ATS_CSS]["colors"]["border"],
        WebsiteName: Rails.application.secrets[:ATS_NAME]["website_name"],
        MainLogo: "#{Rails.application.secrets[:BACKEND]}/email_templates/mail-logo.png",
        CompanyImg: "#{Rails.application.secrets[:BACKEND]}/email_templates/mail-logo.png",
        URLRoot: Rails.application.secrets[:BACKEND],
        Website: Rails.application.secrets[:FRONTEND],
        Recruiter: last_change.present? ? last_change.employer.full_name : "NA",
        JobseekerFullName: self.jobseeker.full_name,
        JobseekerUserId: self.jobseeker.user.id,
        JobseekerURLName: self.jobseeker.full_name.gsub!(" ", "-"),
        RequisitionIdNumber: self.job.id,
        TypeOfRequisition: self.job.employment_type ? Job::EMPLOYMENT_TYPE_MAIL[self.job.employment_type] : "NA",
        Grade: self.job.position.try(:grade).try(:name) || "NA",
        JobSeekerId: self.jobseeker.user.id,
        JobSeekerFullName: self.jobseeker.full_name,
        MobileNumber: self.jobseeker.mobile_phone,
        EmailId: self.jobseeker.email,
        NationalIdNumber: self.jobseeker.id_number,
        Requester: self.job.user.full_name
    }
    template_values

  end

  def export_history_to_csv
    CSV.generate({}) do |csv|
      first_row = ["#","Candidate Name", "Email", "Job Name", "Stage Name", "Stage Created On", "Stage Duration In Days", "Creation User Name", "Creation User Dept", "Application Creation Date", "Application Last Date", "Application Duration in Days" ]
      csv << first_row
      candidate_name = self.jobseeker.full_name
      email = self.jobseeker.user.email
      job_name = self.job.title
      stage_name = '';
      stage_created_on = '';
      stage_duration = 0;
      user_name = ''
      user_depts = ''
      application_created_on = self.created_at
      application_end_on = ''
      application_duration = 0

      self.job_application_status_changes.each_with_index do |sel_val, sel_index|

        stage_name = sel_val.job_application_status.status
        stage_created_on = sel_val.created_at
        stage_duration = 0
        if (self.job_application_status_changes[sel_index + 1].present?)
          stage_duration =  (self.job_application_status_changes[sel_index + 1].created_at.to_date - sel_val.created_at.to_date).to_i
        else
          stage_duration =  (Date.today - sel_val.created_at.to_date).to_i
          application_end_on = sel_val.created_at
        end
        application_duration += stage_duration
        user_name = sel_val.employer.full_name
        user_depts = sel_val.employer.organizations.map{|a| a.try(:name)}




        sel_row = [sel_index + 1, candidate_name, email, job_name, stage_name, stage_created_on, stage_duration,
                   user_name, user_depts, application_created_on, application_end_on, application_duration]
        csv << sel_row
      end

    end

  end

  def self.scan_medical_insurance file
    xlsx = Roo::Spreadsheet.open(file['medical_insurance_document'] , extension: :xlsx)
    puts xlsx.info
    scan_list = []
    (0..2).each do |sel_sheet_index|
      sel_sheet = xlsx.sheet(sel_sheet_index)

      (3..sel_sheet.last_row).each do |col_num|
        en_name = sel_sheet.cell('A', col_num)
        ar_name = sel_sheet.cell('B', col_num)
        dob =  sel_sheet.cell('C', col_num).strftime("%m/%d/%Y")
        id_number = sel_sheet.cell('D', col_num)
        nationality = sel_sheet.cell('E', col_num)
        nationality_id = Country.where(Country.arel_table[:name].matches(sel_sheet.cell('E', col_num).squish)).try(:last).try(:id)
        gender = sel_sheet.cell('F', col_num)
        type = xlsx.sheets[sel_sheet_index].downcase
        scan_list.push({en_name: en_name, ar_name: ar_name, dob: dob, id_number: id_number,
                        nationality_id: nationality_id, nationality: nationality, gender: gender, type: type})
      end
    end

    scan_list
  end

  def reminder_submit_evaluation_form

    template_values = self.get_feedback_template_values

    selected_interview = self.interviews.is_selected.last || self.interviews.last
    creator = self.job_application_status_changes.interviewed.last.employer

    template_values[:RecruiterName] = creator.full_name
    template_values[:AssessmentCoordinator] = creator.full_name

    template_values[:AppointmentDate] = selected_interview.appointment_time_zone.try(:strftime, "%d %b, %Y")
    template_values[:HijriAppointmentDate] = selected_interview.appointment_time_zone.try(:to_date).try(:to_hijri).try(:strftime, '%d %B, %Y')
    template_values[:AppointmentTime] = selected_interview.appointment_time_zone.try(:strftime, "%I:%M %p")

    template_values[:InterviewDate] = selected_interview.appointment_time_zone.try(:strftime, "%d %b, %Y")
    template_values[:HijriInterviewDate] = selected_interview.appointment_time_zone.try(:to_date).try(:to_hijri).try(:strftime, '%d %B, %Y')
    template_values[:InterviewTime] = selected_interview.appointment_time_zone.try(:strftime, "%I:%M %p")

    template_values[:TimeZone] = "الرياض"
    template_values[:Duration] = "#{selected_interview.duration}&nbsp;دقيقة"
    template_values[:InterviewDuration] = "#{selected_interview.duration}&nbsp;دقيقة"


    template_values[:Interviewer] = selected_interview.interview_committee_members.map{|interview_committee_member| interview_committee_member.user.full_name}.join(" & ")

    after_interview_receiver = selected_interview.interview_committee_members.select{|interview_committee_member|
      {email: interview_committee_member.user.email, name: interview_committee_member.user.full_name
      } if EvaluationSubmit.where(user_id: interview_committee_member.user_id, job_application_id: self.id).blank? }


    unless after_interview_receiver.blank?

      self.send_email "fill_evaluation_form_after_interview",
                      after_interview_receiver,
                      {
                          message_body: nil,
                          message_subject: "إدخال نتيجة مقابلة شخصية لوظيفة إدخال نتيجة مقابلة شخصية",
                          template_values: template_values
                      }
    end

  end

  def suggest_interview_assessment
    if self.job.grade && Grade::ASSESSOR_GRADE_NAMES.include?(self.job.grade.name)

      template_values = self.get_feedback_template_values
      # if self.job_application_status_changes.assessment.last.nil?
      #   self.job_application_status_changes.security_clearance.last.initiate_assessment_job_offer
      # end

      creator = User.assessor_coordinator.first || self.job_application_status_changes.assessment.last.try(:employer)

      template_values[:RecruiterName] = creator.full_name
      template_values[:AssessmentCoordinator] = creator.full_name

      # receivers = User.assessor_coordinator.map{|rec| {email: rec.email, name: rec.full_name}} | [{email: creator.email, name: creator.full_name}]
      receivers = User.assessor_coordinator.map{|rec| {email: rec.email, name: rec.full_name}}

      self.send_email "suggest_interview_assessment",
                      receivers,
                      {
                          message_body: nil,
                          message_subject: "نتيجة تقييم المستشار",
                          template_values: template_values
                      }
    end
  end

  def send_english_assessment

    template_values = self.get_feedback_template_values
    # if self.job_application_status_changes.assessment.last.nil?
    #   self.job_application_status_changes.security_clearance.last.initiate_assessment_job_offer
    # end

    creator = User.assessor.first || self.job_application_status_changes.assessment.last.try(:employer)

    template_values[:RecruiterName] = creator.full_name
    template_values[:AssessmentCoordinator] = creator.full_name

    # receivers = User.assessor_coordinator.map{|rec| {email: rec.email, name: rec.full_name}} | [{email: creator.email, name: creator.full_name}]
    receivers = User.assessor.map{|rec| {email: rec.email, name: rec.full_name}} | User.qec_coordinator.map{|rec| {email: rec.email, name: rec.full_name}}

    self.send_email "send_english_assessment",
                    receivers,
                    {
                        message_body: nil,
                        message_subject: "إنتقال المرشح لمرحلة التقييم",
                        template_values: template_values
                    }

  end

  def send_suggested_assessment_interviews
    template_values = self.get_feedback_template_values

    creator = self.job_application_status_changes.assessment.last.employer

    template_values[:RecruiterName] = creator.full_name
    template_values[:AssessmentCoordinator] = creator.full_name


    first_selected_interview = self.interviews.first
    default_text = "لا يوجد مقترح"

    template_values[:DateOfFirstSuggestion] = first_selected_interview.appointment_time_zone.try(:strftime, "%d %b, %Y") || default_text
    template_values[:HijriDateOfFirstSuggestion] = first_selected_interview.appointment_time_zone.try(:to_date).try(:to_hijri).try(:strftime, '%d %B, %Y') || default_text
    template_values[:TimeOfFirstSuggestion] = first_selected_interview.appointment_time_zone.try(:strftime, "%I:%M %p") || default_text

    template_values[:TimeZone] = "الرياض"
    template_values[:DurationOfFirstSuggestion] = "#{first_selected_interview.duration}&nbsp;دقيقة" || default_text

    second_selected_interview = self.interviews.second

    template_values[:DateOfSecondSuggestion] = second_selected_interview.appointment_time_zone.try(:strftime, "%d %b, %Y") || default_text
    template_values[:HijriDateOfSecondSuggestion] = second_selected_interview.appointment_time_zone.try(:to_date).try(:to_hijri).try(:strftime, '%d %B, %Y') || default_text
    template_values[:TimeOfSecondSuggestion] = second_selected_interview.appointment_time_zone.try(:strftime, "%I:%M %p") || default_text

    template_values[:TimeZone] = "الرياض"
    template_values[:DurationOfSecondSuggestion] = "#{second_selected_interview.duration}&nbsp;دقيقة" || default_text

    third_selected_interview = self.interviews.third

    template_values[:DateOfThirdSuggestion] = third_selected_interview.appointment_time_zone.try(:strftime, "%d %b, %Y") || default_text
    template_values[:HijriDateOfThirdSuggestion] = third_selected_interview.appointment_time_zone.try(:to_date).try(:to_hijri).try(:strftime, '%d %B, %Y') || default_text
    template_values[:TimeOfThirdSuggestion] = third_selected_interview.appointment_time_zone.try(:strftime, "%I:%M %p") || default_text

    template_values[:TimeZone] = "الرياض"
    template_values[:DurationOfThirdSuggestion] = "#{third_selected_interview.duration}&nbsp;دقيقة" || default_text

    receivers = User.recruiters_for_job(self.job).map{|rec| {email: rec.email, name: rec.full_name}} | User.assessor.map{|rec| {email: rec.email, name: rec.full_name}}
    self.send_email "send_suggested_interview_assessment",
                    receivers,
                    {
                        message_body: nil,
                        message_subject: "تم تحديد موعد مقابلة شخصية لمرشح",
                        template_values: template_values
                    }
  end

  def send_selected_interview_assessment
    template_values = self.get_feedback_template_values
    default_text = "لا يوجد مقترح"

    selected_interview = self.interviews.is_selected.last || self.interviews.last

    template_values[:AgreedDateOfInterview] = selected_interview.appointment_time_zone.try(:strftime, "%d %b, %Y") || default_text
    template_values[:HijriAgreedDateOfInterview] = selected_interview.appointment_time_zone.try(:to_date).try(:to_hijri).try(:strftime, '%d %B, %Y') || default_text
    template_values[:AgreedTimeOfInterview] = selected_interview.appointment_time_zone.try(:strftime, "%I:%M %p") || default_text
    template_values[:AgreedTimeZone] = "الرياض"
    template_values[:AgreedDurationOfInterview] = "#{selected_interview.duration}&nbsp;دقيقة" || default_text

    creator = self.job_application_status_changes.assessment.last.employer
    if selected_interview.interview_status.nil?

      recruitment_manager = User.recruitment_manager.first
      assessor = User.assessor.first
      # assessor_coordinator = User.assessor_coordinator.first
      # template_values[:RecruitmentManager] = recruitment_manager.full_name
      template_values[:RecruitmentManager] = assessor.full_name
      template_values[:RecruiterName] = creator.full_name

      # receivers = [{email: recruitment_manager.email, name: recruitment_manager.full_name}]
      receivers = [{email: assessor.email, name: assessor.full_name}]


      self.send_email "select_interview_assessment",
                      receivers,
                      {
                          message_body: nil,
                          message_subject: "مقابلة شخصية للوظيفة",
                          template_values: template_values
                      }
    else
      recruitment_manager = User.recruitment_manager.first

      template_values[:RecruitmentManager] = recruitment_manager.full_name
      template_values[:RecruiterName] = creator.full_name

      receivers = [{email: recruitment_manager.email, name: recruitment_manager.full_name}]

      self.send_email "result_interview_assessment",
                      receivers,
                      {
                          message_body: nil,
                          message_subject: " نتيجة المقابلة الشخصية لوظيفة",
                          template_values: template_values
                      }

    end
  end

  def ask_to_security_clearence
    template_values = self.get_feedback_template_values

    creator = self.job_application_status_changes.security_clearance.last.employer

    template_values[:RecruiterName] = creator.full_name
    template_values[:SecurityClearanceOfficerName] = User.security_clearence_officers.first.full_name

    User.security_clearence_officers.each_with_index do |user, index|
      template_values[:SecurityClearanceOfficerName] = user.full_name

      receivers = [{email: user.email, name: user.full_name}]
      cc_receivers = [{email: self.job.user.email, name: self.job.user.full_name}] | User.recruiters_for_job(self.job).map{|rec| {email: rec.email, name: rec.full_name}}

      if index == 0
        receivers = receivers | cc_receivers
      end


      self.delay(run_at: ((index+1)*10).seconds.from_now).send_email "ask_to_security_clearence", receivers,
                                                                     {
                                                                         message_body: nil,
                                                                         message_subject: "طلب متابعة ملف مرشح لإصدار تقرير التزكية المنية",
                                                                         template_values: template_values
                                                                     }

      sleep 1
    end
  end

  def reminder_late_shared_candidates
    template_values = self.get_feedback_template_values

    receivers = [{email: self.job.user.email, name: self.job.user.full_name}]

    template_values[:RecruiterName] = self.job.user.full_name

    self.send_email "reminder_shared_candidate",
                    receivers,
                    {
                        message_body: nil,
                        message_subject: " تم ترشيح بعض المرشحين لوظيفة ",
                        template_values: template_values
                    }
  end

  def check_and_send_notification
    template_values = self.get_feedback_template_values

    if self.job_application_status.status == "Applied"

      User.recruiters_for_job(self.job).each_with_index do |rec, index|
        template_values[:RecruiterName] = rec.full_name

        receivers = [{name: rec.full_name, email: rec.email}]

        self.delay(run_at: (index + 10).seconds.from_now).send_email "add_candidate_as_applied",
                                                                     receivers,
                                                                     {
                                                                         message_body: nil,
                                                                         message_subject: " تم ترشيح بعض المرشحين لوظيفة ",
                                                                         template_values: template_values
                                                                     }

      end

      elsif self.job_application_status.status == "Shared"

        creator = self.job_application_status_changes.shared.last.employer

        template_values[:RecruiterName] = creator.full_name

        self.send_email "upload_candidate_by_hiring_manager",
                        [{email: self.job.user.email, name: self.job.user.full_name}, {email: creator.email, name: creator.full_name}],
                        {
                            message_body: nil,
                            message_subject: "تم ترشيح بعض المرشحين لوظيفة",
                            template_values: template_values
                        }

    elsif self.job_application_status.status == "Selected"

      # self.send_email "suggest_interviews",
      #                 [{email: self.job.user.email, name: self.job.user.full_name}],
      #                 {
      #                     message_body: nil,
      #                     message_subject: "موافقة على طلب توظيف – استعراض مواعيد المقابلة",
      #                     template_values: template_values
      #                 }

      receivers = User.recruiters_for_job(self.job).map{|rec| {email: rec.email, name: rec.full_name}}
      template_values = self.get_feedback_template_values

      self.send_email "suggest_interviews",
                      receivers,
                      {
                          message_body: nil,
                          message_subject: "موافقة على طلب توظيف – استعراض مواعيد المقابلة",
                          template_values: template_values
                      }

      # User.recruiters.each_with_index do |rec, index|
      #   template_values = self.get_feedback_template_values
      #   template_values[:Recruiter] = rec.full_name
      #
      #   self.delay(run_at: ((index+1)*10).seconds.from_now).send_email "suggest_interviews",
      #                   [{email: rec.email, name: rec.full_name}],
      #                   {
      #                       message_body: nil,
      #                       message_subject: "موافقة على طلب توظيف – استعراض مواعيد المقابلة",
      #                       template_values: template_values
      #                   }
      #
      #   sleep 1
      #
      # end
    elsif self.job_application_status.status == "Interview"
      selected_interview = self.interviews.where(is_selected: true).last || self.interviews.last
      if selected_interview.is_selected || self.try(:interviews).try(:count) == 1
        creator = self.job_application_status_changes.interviewed.last.employer

        template_values[:RecruiterName] = creator.full_name
        template_values[:AssessmentCoordinator] = creator.full_name

        template_values[:AppointmentDate] = selected_interview.appointment_time_zone.try(:strftime, "%d %b, %Y")
        template_values[:HijriAppointmentDate] = selected_interview.appointment_time_zone.try(:to_date).try(:to_hijri).try(:strftime, '%d %B, %Y')
        template_values[:AppointmentTime] = selected_interview.appointment_time_zone.try(:strftime, "%I:%M %p")

        template_values[:InterviewDate] = selected_interview.appointment_time_zone.try(:strftime, "%d %b, %Y")
        template_values[:InterviewTime] = selected_interview.appointment_time_zone.try(:strftime, "%I:%M %p")

        template_values[:TimeZone] = "الرياض"
        template_values[:Duration] = "#{selected_interview.duration}&nbsp;دقيقة"
        template_values[:InterviewDuration] = "#{selected_interview.duration}&nbsp;دقيقة"


        template_values[:Interviewer] = selected_interview.interview_committee_members.map{|interview_committee_member| interview_committee_member.user.full_name}.join(" & ")

        receivers = selected_interview.interview_committee_members.map{|interview_committee_member|
          {email: interview_committee_member.user.email, name: interview_committee_member.user.full_name}} |
            [{email: self.job.user.email, name: self.job.user.full_name}] |
            User.recruiters_for_job(self.job).map{|rec| {email: rec.email, name: rec.full_name}}


        self.send_email "interview_details",
                        receivers,
                        {
                            message_body: nil,
                            message_subject: "تم تحديد موعد مقابلة شخصية لمرشح",
                            template_values: template_values
                        }


        self.delay(run_at: 1.hour.from_now).reminder_submit_evaluation_form

        # after_interview_receiver = selected_interview.interview_committee_members.map{|interview_committee_member|
        #   {email: interview_committee_member.user.email, name: interview_committee_member.user.full_name
        #   } if EvaluationSubmit.where(user_id: interview_committee_member.user_id, job_application_id: self.id).blank? }
        #
        # self.delay(run_at: 1.hour.from_now).send_email "fill_evaluation_form_after_interview",
        #                 after_interview_receiver,
        #                 {
        #                     message_body: nil,
        #                     message_subject: "إدخال نتيجة مقابلة شخصية لوظيفة إدخال نتيجة مقابلة شخصية",
        #                     template_values: template_values
        #                 }
      end
    elsif self.job_application_status.status == "PassInterview"
      selected_interview = self.interviews.last

      template_values[:AppointmentDate] = selected_interview.appointment_time_zone.try(:strftime, "%d %b, %Y")
      template_values[:AppointmentTime] = selected_interview.appointment_time_zone.try(:strftime, "%I:%M %p")

      template_values[:InterviewDate] = selected_interview.appointment_time_zone.try(:strftime, "%d %b, %Y")
      template_values[:InterviewTime] = selected_interview.appointment_time_zone.try(:strftime, "%I:%M %p")

      template_values[:TimeZone] = "الرياض"
      template_values[:Duration] = "#{selected_interview.duration}&nbsp;دقيقة"
      template_values[:InterviewDuration] = "#{selected_interview.duration}&nbsp;دقيقة"

      User.recruiters_for_job(self.job).each_with_index do |rec, index|
        template_values[:RecruiterName] = rec.full_name

        receivers = [{name: rec.full_name, email: rec.email}]

        self.delay(run_at: (index + 10).seconds.from_now).send_email "passed_interview",
                        receivers,
                        {
                            message_body: nil,
                            message_subject: " اجتياز المقابلة الشخصية للمرشح على وظيفة ",
                            template_values: template_values
                        }

      end


      # selected_interview.interview_committee_members.each_with_index do |interview_committee_member, index|
      #   template_values = self.get_feedback_template_values
      #   template_values[:Interviewer] = interview_committee_member.user.full_name
      #   template_values[:AppointmentDate] = selected_interview.appointment_time_zone.try(:strftime, "%d %b, %Y")
      #   template_values[:AppointmentTime] = selected_interview.appointment_time_zone.try(:strftime, "%I:%M %p")
      #   template_values[:TimeZone] = "",
      #   template_values[:Duration] = "#{selected_interview.duration}&nbsp;دقيقة"
      #
      #
      #   self.delay(run_at: ((index+1)*10).seconds.from_now).send_email "interview_details",
      #                   [{email: interview_committee_member.user.email, name: interview_committee_member.user.full_name}],
      #                   {
      #                       message_body: nil,
      #                       message_subject: "تم تحديد موعد مقابلة شخصية لمرشح",
      #                       template_values: template_values
      #                   }
      #
      #
      #   appointment_time_greater = [selected_interview.appointment_time_zone, DateTime.now].max
      #   self.delay(run_at: appointment_time_greater + 30.minutes + ((index+1)*10).seconds).send_email "interview_finished",
      #                   [{email: interview_committee_member.user.email, name: interview_committee_member.user.full_name}],
      #                   {
      #                       message_body: nil,
      #                       message_subject: "طلب تعبئة نموذج تقييم مقابلة مرشح",
      #                       template_values: template_values
      #                   }
      #
      #   sleep 1
      #
      # end
    elsif self.job_application_status.status == "Assessment"
      if self.job_application_status_changes.assessment.last.try(:interviews).try(:count) > 1

        self.send_suggested_assessment_interviews

      elsif self.job_application_status_changes.assessment.last.try(:interviews).try(:count) == 1 || !self.job_application_status_changes.assessment.last.try(:interviews).try(:is_selected).blank?
        self.send_selected_interview_assessment
      elsif self.job_application_status_changes.assessment.last.try(:interviews).try(:count) == 0
        if (self.job.grade && ['Level 2', 'Level 3', 'Level 4'].include?(self.job.grade.name))

          self.suggest_interview_assessment
        else
          self.send_english_assessment
        end
      end

    elsif self.job_application_status.status == "SecurityClearance"
      self.ask_to_security_clearence

      self.suggest_interview_assessment

      self.move_to_job_offer

    elsif self.job_application_status.status == "JobOffer" && self.jobseeker.candidate_type == 'external'
      # NO THING TO DO!
      # self.move_to_job_offer

    elsif self.job_application_status.status == "OnBoarding"

      # onboarding_status_change = self.job_application_status_changes.onboarding.last
      #
      # name_template = if onboarding_status_change.offer_requisition_status == 'sent'
      #                   'move_to_onboarding'
      #                   elsif onboarding_status_change.on_boarding_status == 'rejected'
      #                 end
      #
        if self.job_application_status_changes.last.on_boarding_status == 'beginning'

          if self.employment_type == 'external'
            receivers = User.recruiters_for_job(self.job).map{|rec| {email: rec.email, name: rec.full_name}}

            receivers.each_with_index do |receiver, index|
              template_values[:RecruiterName] = receiver[:name]

              self.delay(run_at: ((index+1)*10).seconds.from_now).send_email "move_to_onboarding",
                                                                             [receiver],
                                                                             {
                                                                                 message_body: nil,
                                                                                 message_subject: "الانتقال الى مرحلة ما بعد التعيين ",
                                                                                 template_values: template_values
                                                                             }

              sleep 1
            end

            self.delay.send_email "move_to_onboarding",
                                  [{email: User.recruitment_manager.first.email, name: User.recruitment_manager.first.full_name}],
                                  {
                                      message_body: nil,
                                      message_subject: "الموافقة على العرض الوظيفي والانتقال لمرحلة ما بعد التعيين",
                                      template_values: template_values
                                  }
          else
            receivers = User.recruiters_for_job(self.job).map{|rec| {email: rec.email, name: rec.full_name}}

            receivers.each_with_index do |receiver, index|
              template_values[:RecruiterName] = receiver[:name]

              self.delay(run_at: ((index+1)*10).seconds.from_now).send_email "move_internal_to_onboarding",
                                                                             [receiver],
                                                                             {
                                                                                 message_body: nil,
                                                                                 message_subject: "الانتقال الى مرحلة ما بعد التعيين ",
                                                                                 template_values: template_values
                                                                             }

              sleep 1
            end

            self.delay.send_email "move_internal_to_onboarding",
                                  [{email: User.recruitment_manager.first.email, name: User.recruitment_manager.first.full_name}],
                                  {
                                      message_body: nil,
                                      message_subject: "الموافقة على العرض الوظيفي والانتقال لمرحلة ما بعد التعيين",
                                      template_values: template_values
                                  }

          end


        end
    end
  end


  def move_to_job_offer
    if self.jobseeker.candidate_type == 'external'
      template_values = self.get_feedback_template_values

      creator = self.job_application_status_changes.security_clearance.last.employer

      template_values[:RecruiterName] = creator.full_name

      receivers = [{email: self.job.user.email, name: self.job.user.full_name}, {email: creator.email, name: creator.full_name}] | User.recruitment_manager.map{|rec| {email: rec.email, name: rec.full_name}}

      self.send_email "move_to_job_offer",
                      receivers,
                      {
                          message_body: nil,
                          message_subject: "إنتقال المرشح لمرحلة العرض الوظيفي",
                          template_values: template_values
                      }
    end
  end

  # TODO: Remove this
  def test_fill_evaluation_form
    template_values = self.get_feedback_template_values
    selected_interview = self.interviews.first
    selected_interview.interview_committee_members.each do |interview_committee_member|
      template_values = self.get_feedback_template_values
      template_values[:Interviewer] = interview_committee_member.user.full_name
      template_values[:AppointmentDate] = selected_interview.appointment_time_zone.try(:strftime, "%d %b, %Y")
      template_values[:AppointmentTime] = selected_interview.appointment_time_zone.try(:strftime, "%I:%M")
      template_values[:TimeZone] = (selected_interview.appointment_time_zone.try(:strftime, "%p") == 'AM')? 'صباحا': 'مساء',
      template_values[:Duration] = "#{selected_interview.duration}"

      self.delay.send_email "interview_finished",
                      [{email: interview_committee_member.user.email, name: interview_committee_member.user.full_name}],
                      {
                          message_body: nil,
                          message_subject: "طلب تعبئة نموذج تقييم مقابلة مرشح",
                          template_values: template_values
                      }
    end
  end

  def review_evaluation_form

    template_values = self.get_feedback_template_values

    selected_interview = self.interviews.is_selected.last || self.interviews.last
    template_values[:RecruiterName] = self.job.user.full_name
    template_values[:Interviewer] = selected_interview.interview_committee_members.map{|interview_committee_member| interview_committee_member.user.full_name}.join(" & ")
    template_values[:AppointmentDate] = selected_interview.appointment_time_zone.try(:strftime, "%d %b, %Y")
    template_values[:AppointmentTime] = selected_interview.appointment_time_zone.try(:strftime, "%I:%M %p")
    template_values[:TimeZone] = selected_interview.time_zone
    template_values[:Duration] = "#{selected_interview.duration} Minutes"

    # self.send_email "review_evaluation_form",
    #                 [{email: self.job.user.email, name: self.job.user.full_name}],
    #                 {
    #                     message_body: nil,
    #                     message_subject: "طلب مراجعة نماذج تقييم مرشح",
    #                     template_values: template_values
    #                 }


    self.send_email "after_submit_evaluation_form",
                    [{email: self.job.user.email, name: self.job.user.full_name}],
                    {
                        message_body: nil,
                        message_subject: "اكتمال نتيجة المقابلة الشخصية للمرشح على وظيفة",
                        template_values: template_values
                    }

    # selected_interview = self.interviews.first
    # selected_interview.interview_committee_members.each do |interview_committee_member|
    #   template_values[:Interviewer] = interview_committee_member.user.full_name
    #   template_values[:AppointmentDate] = selected_interview.appointment_time_zone.try(:strftime, "%d %b, %Y")
    #   template_values[:AppointmentTime] = selected_interview.appointment_time_zone.try(:strftime, "%I:%M %p")
    #   template_values[:TimeZone] = selected_interview.time_zone
    #   template_values[:Duration] = "#{selected_interview.duration} Minutes"
    #
    #
    #   self.send_email "review_evaluation_form",
    #                   [{email: self.job.user.email, name: self.job.user.full_name}],
    #                   {
    #                       message_body: nil,
    #                       message_subject: "طلب مراجعة نماذج تقييم مرشح",
    #                       template_values: template_values
    #                   }
    # end
  end

  def check_and_send_notification_old
    template = "job_applicant"

    if self.job.notification_type == 1 && false
      template = Tilt::ERBTemplate.new("#{Dir.pwd}/app/views/api/v1/notifier/applicants.html.erb")
      output = template.render(self.job.company, company: self.job.company, job: self.job, applicants: [self.jobseeker])

      # receivers = self.job.company.users.map{|user| {email: user.email, name: user.full_name}}
      receivers = [{email: self.job.user.email, name: self.job.user.full_name}]
      self.send_email("Applicants for #{self.job.title}",
                      receivers,
                      {
                          message_subject: "New applicants for the position #{self.job.title}",
                          message_body: output
                      })
    end

    #   Send To Jobseeker
    # confirmation_template = Tilt::ERBTemplate.new("#{Dir.pwd}/app/views/api/v1/job_applications/confirmation_jobseeker.html.erb")
    # output = confirmation_template.render(self.jobseeker, company: self.job.company, job: self.job, user: self.jobseeker.user)
    #
    # self.send_email("Application Submission for #{self.job.title}",
    #                 [{email: self.jobseeker.user.email, name: self.jobseeker.full_name}],
    #                 {
    #                     message_subject: "Application Submission for #{self.job.title}",
    #                     message_body: output
    #                 })
  end

  def selected_interview_select_stage
    interviews = self.job_application_status_changes.selected.first.interviews
    selected_interview = if interviews.is_selected.blank?
                           interviews.first
                         else
                           interviews.is_selected.first
                         end
    selected_interview
  end

  def evaluation_submit
    self.evaluation_submits.first
  end

  def get_answer_by_question_name question_name
    question = EvaluationQuestion.find_by_name(question_name)
    self.evaluation_submit.evaluation_answers.find_by(evaluation_question_id: question.id).try(:answer_text) || 'NA'
  end

  def delete_application(current_user)
    self.update(deleted: true)
    JobHistory.create!(
      job: self.job,
      job_action_type: 'delete_job_application',
      user: current_user,
      record_data: { job_application_id: self.id }
    )
  end

  protected
    def set_job_application_status
      self.job_application_status = JobApplicationStatus.find_by_status("Applied")
    end
end
