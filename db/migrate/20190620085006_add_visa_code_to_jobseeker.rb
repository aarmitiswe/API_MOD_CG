class AddVisaCodeToJobseeker < ActiveRecord::Migration
  def change
    add_column :jobseekers, :visa_code, :string
  end
end
