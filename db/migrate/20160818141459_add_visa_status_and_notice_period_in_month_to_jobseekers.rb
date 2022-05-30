class AddVisaStatusAndNoticePeriodInMonthToJobseekers < ActiveRecord::Migration
  def change
    add_column :jobseekers, :visa_status, :integer, default: 2
    add_column :jobseekers, :notice_period_in_month, :integer, default: 1
  end
end
