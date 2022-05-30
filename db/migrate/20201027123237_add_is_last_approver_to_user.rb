class AddIsLastApproverToUser < ActiveRecord::Migration
  def change
    add_column :users, :is_last_approver, :boolean, default: false
  end
end
