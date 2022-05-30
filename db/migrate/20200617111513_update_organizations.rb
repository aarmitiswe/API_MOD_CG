class UpdateOrganizations < ActiveRecord::Migration
  def change
    remove_column :organizations, :type
    add_column :organizations, :organization_type_id, :integer
  end
end
