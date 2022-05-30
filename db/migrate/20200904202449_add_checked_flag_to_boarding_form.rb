class AddCheckedFlagToBoardingForm < ActiveRecord::Migration
  def change
    add_column :boarding_forms, :support_management_checked_at, :datetime
    add_column :boarding_forms, :evaluation_performance_checked_at, :datetime
    add_column :boarding_forms, :mod_session_checked_at, :datetime
  end
end
