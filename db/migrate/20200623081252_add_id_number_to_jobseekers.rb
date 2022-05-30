class AddIdNumberToJobseekers < ActiveRecord::Migration
  def change
    add_column :jobseekers, :id_number, :integer
  end
end
