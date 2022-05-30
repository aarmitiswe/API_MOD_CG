class JobseekerListSerializer < ActiveModel::Serializer
  include DateHelper
  delegate :current_user, to: :scope

  attributes :id, :first_name, :last_name, :sector, :default_resume, :video, :video_screenshot, :current_company_name, :id_number, :jobs_applied_to,
             :city, :country, :number_of_viewers, :years_of_experience, :avatar,
             :status, :user_id, :current_position, :job_application, :matching_percentage,
             :num_years_experience,:probability, :is_applied, :application_date, :is_invited, :expected_salary,
             :nationality, :average_rating, :rating_by_current_user, :preferred_position, :jobseeker_type,
             :current_salary, :ref_id, :email, :gender, :mobile_phone, :complete_step, :employment_type,
             :candidate_type, :terminated_at


  has_one :user
  has_one :job_experience_level
  has_one :job_education
  has_many :jobseeker_skills
  has_many :hash_tags
  has_many :jobseeker_educations
  

  def current_company_name
    object.current_experience.try(:company_name)
  end

  def sector
    SectorSerializer.new(object.sector, root: false).serializable_object(serialization_options)
  end

  def city
    CitySerializer.new(object.user_city, root: false).serializable_object(serialization_options)
  end

  def country
    CountrySerializer.new(object.user_country, root: false).serializable_object(serialization_options)
  end

  def nationality
    CountrySerializer.new(object.nationality, root: false).serializable_object(serialization_options)
  end

  def number_of_viewers
    object.jobseeker_profile_views.count + 876
  end

  def years_of_experience
    subtract_to_years_months object.min_experience_date, object.max_experience_date
  end

  def num_years_experience
    object.years_of_experience
  end

  def status
    object.get_job_application_for_job(serialization_options[:job_id]).try(:job_application_status).try(:status)
  end

  def job_application
    application = object.get_job_application_for_job serialization_options[:job_id]
    application ? {
        id: application.id,
        job_id: application.job_id,
        jobseeker_id: application.jobseeker_id,
        status: application.job_application_status.status,
        ar_status: application.job_application_status.ar_status,
        status_id: application.job_application_status_id,
        security_clearance_document: application.security_clearance_document,
        candidate_type: application.candidate_type,
        employment_type: application.employment_type,
        is_security_cleared: application.is_security_cleared,
        candidate_information_document_url: application.candidate_information_document.try(:document).try(:url),
        security_clearance_result_document_url: application.security_clearance_result_document.try(:document).try(:url)
    } : {}
  end

  def is_applied
    !object.get_job_application_for_job(serialization_options[:job_id]).nil?
  end

  def application_date
    object.get_job_application_for_job(serialization_options[:job_id]).try(:created_at)
  end

  def is_invited
    !object.get_invited_for_job(serialization_options[:job_id]).nil?
  end

  def matching_percentage
    object.respond_to?("matching_percentage") ? object.matching_percentage : 0
  end

  def probability
    object.respond_to?("probability") ? object.probability : 0
  end

  def rating_by_current_user
    current_user.my_ratings.where(jobseeker_id: object.id).first
  end

  def ref_id
    object.user.id_6_digits
  end

  def jobs_applied_to
    applications = JobApplication.where(jobseeker_id: object.id)
    ids = []
    applications.each do |app|
      ids << app.job_id
    end
    ids
  end
end
