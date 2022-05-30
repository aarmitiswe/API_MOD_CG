require 'active_support/concern'

module RequisitionBuilder
  extend ActiveSupport::Concern

  included do
    REQUISITION_STATUS = %w(sent approved rejected)


    scope :approved, -> { where(requisition_status: 'approved') }
    scope :sent, -> { where(requisition_status: 'sent') }
    scope :rejected, -> { where(requisition_status: 'rejected') }

    after_commit :create_requisitions,  on: :create
    after_commit :notify_hiring_manager,  on: :create

    def get_all_organizations
      all_organizations = self.organization.try(:all_parent_orgnizations) || []
      all_organizations.insert(0, self.organization)
      all_organizations.compact
    end

    OrganizationType::TYPES.each do |org_type|
      define_method("#{org_type.downcase.parameterize('_')}") { all_organizations = self.get_all_organizations; all_organizations.select{|org| org.organization_type.try(:name) == org_type}.first }
    end

    def approvers_objects
      res = self.requisitions_active.map do |req|
        {
            full_name: req.user.full_name,
            structure: OrganizationUser.find_by_user_id(req.user_id).try(:organization).try(:name) || "NA",
            action: req.status,
            details: "NA",
            reason: req.reason
        }
      end
      res
    end

    def get_highest_organization ancestor_organizations, organization
      all_ancestors = organization.all_parent_orgnizations
      common_organizations = all_ancestors & ancestor_organizations
      res = common_organizations.blank? ? organization : common_organizations.first
      res
    end

    def notify_hiring_manager
      self.send_email_to_hiring_manager
    end

    # This method had been modified to approve all requisitions and do not send email if job id already approved
    def create_requisitions
      already_approved = self.requisition_status == 'approved'
      selected_organization = get_highest_organization(self.user.organizations, self.organization)
      # all_managers_with_organization = self.organization.all_managers_with_organization
      all_managers_with_organization = selected_organization.all_managers_with_organization
      first_requisition = nil
      approver_list = []
      all_managers_with_organization.each do |org_user_obj|
        next unless org_user_obj[:manager].is_approver
        is_approved = org_user_obj[:manager].id == self.user_id
        if approver_list.exclude?(org_user_obj[:manager].id) && (org_user_obj[:organization].nil? || (org_user_obj[:organization].present? && !(["Executive Office", "ExecutiveOffice"].include?(org_user_obj[:organization].organization_type.try(:name)))))
          current = Requisition.create(user_id: org_user_obj[:manager].id,
                             organization_id: org_user_obj[:organization].try(:id),
                             job_id: self.id,
                             status: (is_approved || already_approved ? Requisition::APPROVE_STATUS : Requisition::SENT_STATUS),
                             active: is_approved,
                             approved_at: is_approved ? DateTime.now : nil)
          approver_list << org_user_obj[:manager].id
          first_requisition ||= current
        end
      end
      first_requisition.check_next_requisition if !already_approved
      # Requisition.send_mail_to_next_user self
    end

    def is_approved?
      self.requisitions_active.count.zero? || self.requisitions_active.all?{|req| req.status == Requisition::APPROVE_STATUS}
    end

    def is_rejected?
      !self.requisitions_active.blank? && self.requisitions_active.map(&:status).include?(Requisition::REJECT_STATUS)
    end

    def is_sent?
      !self.requisitions_active.blank? && self.requisitions_active.map(&:status).include?(Requisition::SENT_STATUS)
    end

    def self.update_all_requisition_status
      Job.where.not(id: Requisition.pluck(:job_id)).update_all(requisition_status: Requisition::APPROVE_STATUS)
      Requisition.sent.each{|req| req.job.update_column(:requisition_status, Requisition::SENT_STATUS)}
      Requisition.rejected.each{|req| req.job.update_column(:requisition_status, Requisition::REJECT_STATUS)}
      Job.where(requisition_status: nil).update_all(requisition_status: Requisition::APPROVE_STATUS)
    end
  end
end
