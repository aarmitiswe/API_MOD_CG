class ChangeVisaStatusInJobseeker < ActiveRecord::Migration
  def change
    remove_column :jobseekers, :visa_status, :integer
    add_reference :jobseekers, :visa_status, index: true, foreign_key: :visa_status_id
  end
end
