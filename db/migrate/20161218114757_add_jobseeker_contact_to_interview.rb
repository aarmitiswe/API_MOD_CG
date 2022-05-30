class AddJobseekerContactToInterview < ActiveRecord::Migration
  def change
    add_column :interviews, :jobseeker_contact, :string
  end
end
