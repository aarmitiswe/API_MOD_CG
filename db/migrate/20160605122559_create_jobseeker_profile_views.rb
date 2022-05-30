class CreateJobseekerProfileViews < ActiveRecord::Migration
  def change
    create_table :jobseeker_profile_views do |t|
      t.references :employer, references: :users
      t.references :jobseeker, references: :users

      t.timestamps null: false
    end
    add_foreign_key :jobseeker_profile_views, :users, column: :employer_id
    add_foreign_key :jobseeker_profile_views, :users, column: :jobseeker_id
  end
end
