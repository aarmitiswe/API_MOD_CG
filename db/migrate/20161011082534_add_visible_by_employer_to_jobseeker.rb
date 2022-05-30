class AddVisibleByEmployerToJobseeker < ActiveRecord::Migration
  def change
    add_column :jobseekers, :visible_by_employer, :boolean
  end
end
