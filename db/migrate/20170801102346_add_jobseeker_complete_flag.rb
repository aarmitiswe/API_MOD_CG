class AddJobseekerCompleteFlag < ActiveRecord::Migration
  def change
    add_column :jobseekers, :profile_completed, :boolean , default: false
  end
end
