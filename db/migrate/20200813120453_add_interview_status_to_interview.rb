class AddInterviewStatusToInterview < ActiveRecord::Migration
  def change
    add_column :interviews, :interview_status, :string
  end
end
