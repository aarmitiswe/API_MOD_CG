class AddOrganizationToRequisition < ActiveRecord::Migration
  def change
    add_reference :requisitions, :organization, index: true, foreign_key: :organization_id
  end
end
