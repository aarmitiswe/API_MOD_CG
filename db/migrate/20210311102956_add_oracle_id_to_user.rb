class AddOracleIdToUser < ActiveRecord::Migration
  def change
    add_column :users, :oracle_id, :integer
  end
end
