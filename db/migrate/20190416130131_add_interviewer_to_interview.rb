class AddInterviewerToInterview < ActiveRecord::Migration
  def change
    add_column :interviews, :interviewer_id, :integer, index: true
    add_foreign_key :interviews, :users, column: :interviewer_id
  end
end
