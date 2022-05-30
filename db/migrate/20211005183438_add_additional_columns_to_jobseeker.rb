class AddAdditionalColumnsToJobseeker < ActiveRecord::Migration
  def change
    add_column :jobseekers, :religion, :string
    add_column :jobseekers, :grandfather_name, :string
    add_column :jobseekers, :effective_start_date, :date
    add_column :jobseekers, :oracle_id, :integer
  end
end
