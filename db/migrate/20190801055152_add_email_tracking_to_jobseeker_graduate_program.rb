class AddEmailTrackingToJobseekerGraduateProgram < ActiveRecord::Migration
  def change
    add_column :jobseeker_graduate_programs, :rejection_sent_at, :datetime
  end
end
