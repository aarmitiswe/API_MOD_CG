class JobAuthorizedSerializer < ActiveModel::Serializer
  delegate :current_user, to: :scope

  attributes :id,
             :title,
             :description,
             :qualifications,
             :requirements,
             :is_featured,
             :start_date,
             :end_date,
             :applied_date,
             :created_at,
             :join_date,
             :experience_from,
             :experience_to,
             :notification_type,
             :license_required,
             :company,
             :branch,
             :department,
             :gender_type,
             :marital_status,
             :is_saved_by_current_user,
             :matching_percentage,
             :deleted,
             :active,
             :views_count,
             :count_applications,
             :country_required,
             :city_required,
             :nationality_required,
             :gender_required,
             :age_required,
             :years_of_exp_required,
             :experience_level_required,
             :language_required,
             :job_request_id,
             :is_internal_hiring,
             :user,
             :job_department,
             :requisitions,
             :requisition_status,
             :employment_type,
             :approved_at,
             :has_security_clearance_applicants,
             :is_having_hired_candidates



  has_one :job_type
  has_one :job_status
  has_one :job_category
  has_one :functional_area
  has_one :sector
  has_one :job_education
  has_one :job_experience_level
  has_one :country
  has_one :city
  has_many :recruiters, each_serializer: UserSerializer, root: :recruiters
  has_one :visa_status
  has_one :salary_range
  has_one :age_group
  has_one :position
  has_one :organization
  has_many :benefits
  has_many :job_skills, each_serializer: JobSkillSerializer, root: :skills
  has_many :job_certificates, each_serializer: JobCertificateSerializer, root: :certificates
  # has_many :job_geo_groups, each_serializer: JobGeoGroupSerializer, root: :geo_groups
  has_many :job_countries, each_serializer: JobCountrySerializer, root: :geo_countries
  has_many :languages, each_serializer: LanguageSerializer, root: :languages

  def company
    {
      id:                        object.company.id,
      name:                      object.company.name,
      is_follow_by_current_user: current_user.present? ? object.company.is_follow_by_user(current_user) : false,
      avatar: object.company.avatar,
      sector: SectorSerializer.new(object.company.sector, root: false).serializable_object(serialization_options)
    } if object.company
  end

  def has_security_clearance_applicants
    !object.job_applications.security_clearance.count.zero?
  end

  def branch
    BranchSerializer.new(object.branch, root: false).serializable_object(serialization_options)
  end

  def applied_date
    object.applied_date(current_user) if current_user.present?
  end

  def is_saved_by_current_user
    object.is_saved_by_user(current_user) if current_user.present?
  end

  #@toDo: Removing picking company section if no sector. But it to confirm if no causing issues
  # def sector
  #   SectorSerializer.new(object.sector || object.company.try(:sector), root: false).serializable_object(serialization_options)
  # end

  def matching_percentage
    object.respond_to?(:matching_percentage) ? object.matching_percentage : 0
  end

  def job_request_id
    object.job_request.try(:id)
  end

  def job_department
    object.try(:job_request).try(:hiring_manager).try(:department)
  end

  def requisitions
    object.requisitions_active.order(created_at: :asc).map do |req| {
        id: req.id, reason: req.reason, job_id: req.job_id,
        user: UserSerializer.new(req.user, root: false),
        status: req.status, updated_at: req.updated_at,
        approved_at: req.approved_at,
        organization: req.organization_id.present? ? {
            id: req.organization_id,
            name: req.organization.try(:name)
        } : {
            id: nil,
            name: "مدير قسم تخطيط القوى البشرية"
        }
    }
    end
  end

  def is_having_hired_candidates
    object.job_applications.where(job_application_status_id: JobApplicationStatus.find_by_status('Completed').id).count > 0
  end

end
