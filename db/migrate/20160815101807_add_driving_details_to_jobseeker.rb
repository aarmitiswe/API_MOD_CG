class AddDrivingDetailsToJobseeker < ActiveRecord::Migration
  def change
    add_column :jobseekers, :driving_license_country_id, :integer, references: :countries
    add_column :jobseekers, :driving_license_start_date, :date
    add_column :jobseekers, :driving_license_end_date, :date
  end
end
