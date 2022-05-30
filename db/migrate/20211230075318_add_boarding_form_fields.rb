class AddBoardingFormFields < ActiveRecord::Migration
  def change
    add_column :job_application_status_changes, :it_management, :boolean, default: false
    add_column :job_application_status_changes, :business_service_management, :boolean, default: false
    add_column :job_application_status_changes, :security_management, :boolean, default: false

    add_column :boarding_forms, :it_management_checked_at, :datetime
    add_column :boarding_forms, :business_service_management_checked_at, :datetime
    add_column :boarding_forms, :security_management_checked_at, :datetime
  end
end
