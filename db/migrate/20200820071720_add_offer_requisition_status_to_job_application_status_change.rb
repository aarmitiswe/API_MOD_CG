class AddOfferRequisitionStatusToJobApplicationStatusChange < ActiveRecord::Migration
  def change
    add_column :job_application_status_changes, :offer_requisition_status, :string
  end
end
