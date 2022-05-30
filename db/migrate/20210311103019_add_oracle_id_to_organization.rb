class AddOracleIdToOrganization < ActiveRecord::Migration
  def change
    add_column :organizations, :oracle_id, :integer
  end
end
