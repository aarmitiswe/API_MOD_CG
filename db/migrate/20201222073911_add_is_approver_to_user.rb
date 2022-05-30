class AddIsApproverToUser < ActiveRecord::Migration
  def change
    add_column :users, :is_approver, :boolean, default: true
  end
end
