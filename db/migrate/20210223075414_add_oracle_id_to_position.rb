class AddOracleIdToPosition < ActiveRecord::Migration
  def change
    add_column :positions, :oracle_id, :integer
  end
end
