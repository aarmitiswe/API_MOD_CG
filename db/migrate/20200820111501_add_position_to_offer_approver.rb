class AddPositionToOfferApprover < ActiveRecord::Migration
  def change
    add_column :offer_approvers, :position, :string
  end
end
