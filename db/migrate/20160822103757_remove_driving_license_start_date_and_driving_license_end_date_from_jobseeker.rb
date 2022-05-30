class RemoveDrivingLicenseStartDateAndDrivingLicenseEndDateFromJobseeker < ActiveRecord::Migration
  def change
    remove_column :jobseekers, :driving_license_start_date
    remove_column :jobseekers, :driving_license_end_date
  end
end
