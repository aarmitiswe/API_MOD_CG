class CreateJobseeker < ActiveRecord::Migration
  def change
    create_table :jobseekers do |t|
      t.text :focus
      t.text :summary
      t.string :mobile_phone
      t.string :home_phone
      t.float :current_salary
      t.float :expected_salary
      t.float :years_of_experience
      t.string :marital_status
      t.string :languages
      t.string :profile_video
      t.string :profile_video_image


      t.string :website
      t.string :zip
      t.string :address_line1
      t.string :address_line2
      t.string :google_plus_page_url
      t.string :linkedin_page_url
      t.string :facebook_page_url
      t.string :skype_id



      t.references :user, index: true
      t.references :job_type, index: true
      t.references :job_category, index: true
      t.references :functional_area, index: true
      t.references :job_experience_level, index: true
      t.references :sector, index: true
      t.references :country, index: true
      t.references :current_city
      t.references :current_country
      t.references :nationality
      t.references :job_education, index: true

      t.timestamps null: false
    end
    add_foreign_key :jobseekers, :users
    add_foreign_key :jobseekers, :job_types
    add_foreign_key :jobseekers, :job_categories
    add_foreign_key :jobseekers, :functional_areas
    add_foreign_key :jobseekers, :job_experience_levels
    add_foreign_key :jobseekers, :sectors
    add_foreign_key :jobseekers, :job_educations
  end
end
