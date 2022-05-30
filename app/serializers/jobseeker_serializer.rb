class JobseekerSerializer < ActiveModel::Serializer
  attributes :id,
             :focus,
             :summary,
             :mobile_phone,
             :home_phone,
             :current_salary,
             :expected_salary,
             :years_of_experience,
             :marital_status,
             :languages,
             :profile_video,
             :profile_video_image,
             :website,
             :google_plus_page_url,
             :linkedin_page_url,
             :facebook_page_url,
             :twitter_page_url,
             :skype_id,
             :nationality,
             :address_line1,
             :address_line2,
             :zip,
             :companies,
             :address,
             :driving_license_issued_from,
             :current_experience,
             :document_nationality_id,
             :employment_type,
             :candidate_type

  has_one :user, serializer: JobseekerUserSerializer
  has_one :job_education
  has_one :job_category
  has_one :job_experience_level
  has_one :sector
  has_one :functional_area
  has_one :nationality, serializer: NationalitySerializer
  has_one :job_type
  has_one :current_city
  has_one :current_country
  has_many :jobseeker_experiences, root: :experience
  has_many :jobseeker_educations, root: :education
  has_many :jobseeker_resumes, root: :resume
  has_many :jobseeker_coverletters, root: :coverletter
  has_many :jobseeker_skills, root: :skills
  has_many :jobseeker_certificates, root: :certificates
  has_many :jobseeker_tags, root: :tags

  def id
    object.id
  end

  def companies
    object.user.companies
  end

  def address
    {address_line: object.address_line1, postal_code: object.zip, city_id: object.current_city_id, city_name: City.find_by_id(object.current_city_id).try(:name), country_code: "", country_name: Country.find_by_id(object.current_country_id).try(:name)}
  end

  def driving_license_issued_from
    drive_country = object.driving_license_country
    {code: drive_country.try(:iso), country: drive_country.try(:name)}
  end

end
