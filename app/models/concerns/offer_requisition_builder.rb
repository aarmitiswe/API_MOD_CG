require 'active_support/concern'

module OfferRequisitionBuilder
  extend ActiveSupport::Concern

  included do
    REQUISITION_STATUS = %w(sent approved rejected)

    after_create :build_offer_requisition

    # def build_offer_requisition
    #   if self.is_joboffer?
    #     OfferRequisition.create(user_id: OfferApprover.first.user.id, job_application_id: self.job_application_id, status: 'sent')
    #     self.update(offer_requisition_status: 'sent')
    #   end
    # end

    def build_offer_requisition
      OfferRequisition.create(user_id: OfferApprover.is_new_offer.order(:level).first.user.id, job_application_id: self.job_application_id, status: 'sent', salary_analysis_id: self.salary_analysis.id, offer_analysis_id: self.id)
      self.job_application.last_job_application_status_change.update(offer_requisition_status: 'sent')
    end
  end
end
