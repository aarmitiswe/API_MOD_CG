class JobseekerProfileSerializer < ActiveModel::Serializer
  attributes :id,
	           :objectID,
             :jobseeker_id,
             :first_name,
             :last_name,
             :social_media,
             :summary,
             :address,
             :contact,
             :general_info,
             :skills,
             :summary,
             :avatar,
             :video,
             :video_screenshot,
             :city,
             :country,
             :current_experience,
             :last_active,
             :matching_percentage,
             :is_applied,
             :job_application,
             :job_application_extra_doc_url,
             :profile_completed,
             :complete_step,
             :notification,
             :preferred_position,
             :average_rating,
             :jobseeker_type,
             :num_dependencies,
             :visa_code,
             :ref_id,
             :visa_code,
             :num_dependencies,
             :jobseeker_type,
             :nationality_id_number,
             :id_number,
             :ref_id,
             :employment_type,
             :candidate_type,
             :terminated_at,
             :oracle_id

  has_one :user, serializer: JobseekerUserSerializer
  has_one :job_education, root: :job_education, serializer: JobEducationSerializer
  has_one :job_category, root: :job_category, serializer: JobCategorySerializer
  has_one :job_experience_level, root: :job_experience_level, serializer: JobExperienceLevelSerializer
  has_one :functional_area, root: :sector, serializer: FunctionalAreaSerializer
  has_one :sector, root: :sector, serializer: SectorSerializer
  has_one :nationality, root: :nationality, serializer: NationalitySerializer
  has_one :job_type, root: :job_type, serializer: JobTypeSerializer

  has_many :jobseeker_experiences, root: :work_experience, serializer: JobseekerExperienceSerializer
  has_many :jobseeker_educations, root: :education
  has_many :jobseeker_resumes, root: :resumes
  has_many :jobseeker_coverletters, root: :coverletters
  has_many :jobseeker_skills, root: :skills
  has_many :jobseeker_tags, root: :tags
  has_many :jobseeker_certificates, root: :certificate, serializer: JobseekerCertificateSerializer
  has_one :notification, root: :notification, serializer: NotificationSerializer
  has_many :hash_tags
  has_many :bank_accounts
  has_many :medical_insurances
  has_many :jobseeker_on_board_documents


  # def initialize(object, options={})
  #   super
  #   @options = options[:serializer_options] || {}
  # end

  attr_accessor :options

  def objectID
    object.id
  end

  def profile_completed
    true
  end


  def id
    object.user_id
  end

  def jobseeker_id
    object.id
  end

  def first_name
    object.user.first_name
  end

  def last_name
    object.user.last_name
  end

  def country
    CountrySerializer.new(object.user.country, root: false).serializable_object(serialization_options)
  end

  def city
    CitySerializer.new(object.user.city, root: false).serializable_object(serialization_options)
  end

  def social_media
    media = ["facebook", "linkedin", "twitter", "google_plus"]
    social_media_obj = {}
    media.each do |site|
      social_media_obj[site] = object.send("#{site}_page_url")
    end
    social_media_obj["skype"] = object.skype_id
    social_media_obj
  end

  def companies
    object.user.companies
  end

  def address
    {
        address_line1: object.address_line1,
        address_line2: object.address_line2,
        postal_code: object.zip,
        city: CitySerializer.new(object.current_city, root: false).serializable_object(serialization_options),
        country: CountrySerializer.new(object.current_country, root: false).serializable_object(serialization_options)
    }
  end

  def contact
    {
        email_address: object.user.email,
        phone_no: object.home_phone,
        mobile_no: object.mobile_phone,
    }
  end

  def general_info
    {
        sector: SectorSerializer.new(object.sector, root: false).serializable_object(serialization_options),
        functional_area: FunctionalAreaSerializer.new(object.functional_area, root: false).serializable_object(serialization_options),
        highest_edu: JobEducationSerializer.new(object.job_education, root: false).serializable_object(serialization_options),
        total_years_experience: object.years_of_experience,
        current_salary: object.current_salary,
        expected_salary: object.expected_salary,
        experince_level: JobExperienceLevelSerializer.new(object.job_experience_level, root: false).serializable_object(serialization_options),
        job_type: JobTypeSerializer.new(object.job_type, root: false).serializable_object(serialization_options),
        nationality: CountrySerializer.new(object.nationality, root: false).serializable_object(serialization_options),
        languages: object.languages.map{|lan| LanguageSerializer.new(lan, root: false).serializable_object(serialization_options)},
        driving_license_issued_from: CountrySerializer.new(object.driving_license_country, root: false).serializable_object(serialization_options),
        gender: object.user.gender_type,
        marital_status:  object.marital_status,
        visa_status: VisaStatusSerializer.new(object.visa_status, root: false).serializable_object(serialization_options),
        notice_period_in_months: object.notice_period_in_month,
        dob: object.user.birthday ? {day: format_number(object.user.birthday.day), month: format_number(object.user.birthday.month), year: object.user.birthday.year} : {},
        dob_timestamp: object.user.birthday ? object.user.birthday.to_time.to_i : 0,
  	    last_active_timestamp: object.last_active.to_i
    }
  end

  def skills
    object.jobseeker_skills
  end

  def summary
    object.summary
  end

  def matching_percentage
    object.respond_to?(:matching_percentage) ? object.matching_percentage : 0
  end

  def is_applied
    # !object.get_job_application_for_job(options[:job_id]).nil?
    !object.get_job_application_for_job(serialization_options[:job_id]).nil?
  end

  def job_application
    # object.get_job_application_for_job(options[:job_id])
    object.get_job_application_for_job(serialization_options[:job_id])
  end

  def job_application_extra_doc_url
    object.get_job_application_extra_doc_url(serialization_options[:job_id])
  end

  def ref_id
    object.user.id_6_digits
  end

  # def notification
  #   NotificationSerializer.new(object.user.notification).as_json
  # end

  private
    def format_number x
      format('%02d', x)
    end
end
