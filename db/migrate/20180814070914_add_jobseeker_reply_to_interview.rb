class AddJobseekerReplyToInterview < ActiveRecord::Migration
  def change
    add_column :interviews, :jobseeker_reply, :text
  end
end
