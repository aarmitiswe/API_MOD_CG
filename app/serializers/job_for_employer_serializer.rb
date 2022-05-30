class JobForEmployerSerializer < ActiveModel::Serializer
  attributes :id,
             :title,
             :description,
             :qualifications,
             :requirements,
             :is_featured,
             :start_date,
             :end_date,
             :benefits,
             :salary_from,
             :salary_to,
             :experience_from,
             :experience_to,
             :views_count,
             :notification_type,
             :license_required,
             :company,
             :count_applications,
             :created_at

  has_one :job_type
  has_one :job_status
  has_one :job_category
  has_one :functional_area
  has_one :sector
  has_one :job_education
  has_one :job_experience_level
  has_one :country
  has_one :city
  has_many :benefits

  def company
    {id: object.company.id, name: object.company.name} if object.company
  end
end
