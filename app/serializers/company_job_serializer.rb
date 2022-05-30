class CompanyJobSerializer < ActiveModel::Serializer
  delegate :current_user, to: :scope

  attributes :id,
             :title,
             :updated_at,
             :views_count,
             :status,
             :is_featured,
             :count_applications,
             :is_applied_by_current_user,
             :deleted,
             :end_date,
             :job_request_id,
             :user,
             :is_internal_hiring,
             :requisitions,
             :requisition_status,
             :created_at,
             :employment_type

  has_one :sector
  has_one :branch
  has_one :country
  has_one :city
  has_one :company
  has_one :user
  has_one :organization
  has_one :job_status
  has_one :position
  has_many :recruiters


  def is_applied_by_current_user
    object.is_applied_by_user(current_user)
  end

  def job_request_id
    object.job_request.try(:id)
  end

  def requisitions
    is_rejected = false;
    req_json = []
      # Reason for this code. If any approver has rejected .Then result of the remaining approvers are not required
      object.requisitions_active.order(created_at: :asc).each do |req|
        req_json.push({
                        id: req.id,
                        reason: req.reason,
                        job_id: req.job_id,
                        user: UserSerializer.new(req.user, root: false),
                        status: (!is_rejected)? req.status : 'N/A',
                        updated_at: req.updated_at,
                        approved_at: req.approved_at,
                        organization: req.organization_id.present? ? {
                            id: req.organization_id,
                            name: req.organization.try(:name)
                        } : {
                            id: nil,
                            name: "مدير قسم تخطيط القوى البشرية"
                        }
                      }
        )
        is_rejected = (req.status == 'rejected' || is_rejected) ? true : false

      end
    req_json

  end

end
