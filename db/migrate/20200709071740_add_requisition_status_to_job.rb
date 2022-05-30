class AddRequisitionStatusToJob < ActiveRecord::Migration
  def change
    add_column :jobs, :requisition_status, :string
  end
end
