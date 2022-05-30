class AddTermintatedAtToJobApplicationcd < ActiveRecord::Migration
  def change
    add_column :job_applications, :terminated_at, :datetime
  end
end
