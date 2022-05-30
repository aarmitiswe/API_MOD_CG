class AddCompleteStepToJobseeker < ActiveRecord::Migration
  def change
    add_column :jobseekers, :complete_step, :integer
  end
end
