class AddCustomCreditsAndPriceToJobseekerPackageBroadcast < ActiveRecord::Migration
  def change
    add_column :jobseeker_package_broadcasts, :num_credits, :integer
    add_column :jobseeker_package_broadcasts, :price, :float
  end
end
