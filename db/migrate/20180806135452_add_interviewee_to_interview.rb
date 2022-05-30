class AddIntervieweeToInterview < ActiveRecord::Migration
  def change
    add_column :interviews, :interviewee, :string
  end
end
