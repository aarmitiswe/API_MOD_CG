class AddApprovedAtToJob < ActiveRecord::Migration
  def change
    add_column :jobs, :approved_at, :datetime
  end
end
