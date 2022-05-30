class AddCandidateToNotification < ActiveRecord::Migration
  def change
    add_column :notifications, :candidate, :integer
  end
end
