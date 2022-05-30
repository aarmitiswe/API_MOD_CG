class AddIsInterviewerToUser < ActiveRecord::Migration
  def change
    add_column :users, :is_interviewer, :boolean, default: false
  end
end
