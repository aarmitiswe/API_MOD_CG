class AddOrganizationToJobRequest < ActiveRecord::Migration
  def change
    add_reference :job_requests, :organization, index: true, foreign_key: :organization_id
  end
end
