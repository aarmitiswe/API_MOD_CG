class AddIsRecruiterToUser < ActiveRecord::Migration
  def change
    add_column :users, :is_recruiter, :boolean, default: false
  end
end
