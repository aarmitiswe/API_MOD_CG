class AddApprovedAtToRequisition < ActiveRecord::Migration
  def change
    add_column :requisitions, :approved_at, :datetime
  end
end
