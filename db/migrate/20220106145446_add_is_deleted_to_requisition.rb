class AddIsDeletedToRequisition < ActiveRecord::Migration
  def change
    add_column :requisitions, :is_deleted, :boolean, default: false
  end
end
