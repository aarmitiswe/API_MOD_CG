class AddOrganizationToJob < ActiveRecord::Migration
  def change
    add_reference :jobs, :organization, index: true, foreign_key: :organization_id
  end
end
