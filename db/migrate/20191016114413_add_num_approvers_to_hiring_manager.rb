class AddNumApproversToHiringManager < ActiveRecord::Migration
  def change
    add_column :hiring_managers, :num_approvers, :integer, default: 4
  end
end
