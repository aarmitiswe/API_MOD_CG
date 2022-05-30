class AddSharedWithHiringManagerToJobApplication < ActiveRecord::Migration
  def change
    add_column :job_applications, :shared_with_hiring_manager, :boolean
  end
end
