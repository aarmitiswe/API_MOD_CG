# This serializer for public view
class JobSerializer < ActiveModel::Serializer
  attributes :id,
             :objectID,
             :title,
             :description,
             :qualifications,
             :requirements,
             :start_date,
             :end_date,
             :benefits,
             :experience_from,
             :experience_to,
             :views_count,
             :notification_type,
             :count_applications,
             :created_at,
             :gender_type,
             :deleted

  has_one :job_type
  has_one :job_status
  has_one :job_category
  has_one :sector
  has_one :job_education
  has_one :job_experience_level
  has_one :country
  has_one :city
  has_one :organization
  has_one :user
  has_one :salary_range
  has_one :age_group
  has_many :benefits
  has_many :job_skills, each_serializer: JobSkillSerializer, root: :skills
  has_many :job_certificates, each_serializer: JobCertificateSerializer, root: :certificates
  has_many :languages, each_serializer: LanguageSerializer, root: :languages

  def objectID
    object.id
  end

  def company
    {
        id: object.company.id,
        name: object.company.name,
        sector: SectorSerializer.new(object.company.sector, root: false).serializable_object(serialization_options),
        avatar: object.company.avatar
    } if object.company
  end

end
