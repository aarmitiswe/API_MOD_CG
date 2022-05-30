# This serializer for jobs list
class JobListSerializer < ActiveModel::Serializer
  attributes :id,
             :title,
             :company,
             :branch,
             :matching_percentage,
             :probability,
             :job_applications_count,
             :start_date,
             :views_count,
             :created_at,
             :deleted,
             :end_date,
             :job_request

  has_one :sector
  has_one :country
  has_one :city
  has_one :salary_range
  has_one :job_status


  def job_request
    {
        job_request_id: object.try(:job_request).try(:id),
        section: object.try(:job_request).try(:hiring_manager).try(:section),
        new_section: object.try(:job_request).try(:hiring_manager).try(:new_section),
        office: object.try(:job_request).try(:hiring_manager).try(:office),
        unit: object.try(:job_request).try(:hiring_manager).try(:unit),
        grade: object.try(:job_request).try(:hiring_manager).try(:grade),
        department: object.try(:job_request).try(:hiring_manager).try(:department)
    }
  end

  def company
    {
        id: object.company.id,
        name: object.company.name,
        sector: SectorSerializer.new(object.company.sector, root: false).serializable_object(serialization_options),
        avatar: object.company.avatar
    } if object.company
  end

  def branch
    BranchSerializer.new(object.branch, root: false).serializable_object(serialization_options)
  end

  def job_applications_count
    object.job_applications.count
  end

  # def sector
  #   sector = object.sector || object.company.sector
  #   {
  #     id:   sector.try(:id),
  #     name: sector.try(:name)
  #   }
  # end

  def matching_percentage
    object.respond_to?(:matching_percentage) ? object.matching_percentage : 0
  end

  def probability
    object.respond_to?(:probability) ? object.probability : 0
  end
end
