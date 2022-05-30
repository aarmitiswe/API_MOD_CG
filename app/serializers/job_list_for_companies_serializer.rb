class JobListForCompaniesSerializer < ActiveModel::Serializer
  attributes :id, :title, :job_applications_count, :views_count, :days_to_expired, :is_featured,
             :created_at

  has_one :company
  has_one :sector
  has_one :country
  has_one :city

  # TODO: Return # days if no end_date for jobs Or Update DB with max open days for Jobs
  def days_to_expired
    return 1000 if object.end_date.nil?
    (object.end_date - Date.today).to_i
  end

  def company
    {
        id: object.company.id,
        name: object.company.name,
        avatar: object.company.avatar
    }
  end

  def job_applications_count
    object.job_applications.count
  end
end