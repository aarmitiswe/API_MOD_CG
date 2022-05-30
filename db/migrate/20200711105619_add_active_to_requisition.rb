class AddActiveToRequisition < ActiveRecord::Migration
  def change
    add_column :requisitions, :active, :boolean, default: false
  end
end
