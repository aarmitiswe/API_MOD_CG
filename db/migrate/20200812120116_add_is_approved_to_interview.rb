class AddIsApprovedToInterview < ActiveRecord::Migration
  def change
    add_column :interviews, :is_approved, :boolean, default: false
  end
end
