class AddSecurityClearanceColsToJobApplication < ActiveRecord::Migration
  def change
    add_column :job_applications, :security_clearance_document, :string
    add_column :job_applications, :is_security_cleared, :boolean
  end
end
