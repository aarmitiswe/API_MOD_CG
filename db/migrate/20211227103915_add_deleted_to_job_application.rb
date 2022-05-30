class AddDeletedToJobApplication < ActiveRecord::Migration
  def change
    add_column :job_applications, :deleted, :boolean, default: false
  end
end
