class CreateJobs < ActiveRecord::Migration
  def change
    create_table :jobs do |t|

      # jobs data
      t.string :title
      t.text :description
      t.text :qualifications
      t.text :requirements
      t.date :start_date
      t.date :end_date
      t.text :benefits
      t.float :salary_from
      t.float :salary_to
      t.float :experience_from
      t.float :experience_to
      t.integer :views_count
      t.integer :notification_type
      t.string :url
      t.boolean :license_required


      # access control
      t.boolean :active
      t.boolean :deleted

      # references
      t.references :user
      t.references :company
      t.references :job_type
      t.references :job_status
      t.references :job_category
      t.references :functional_area
      t.references :sector
      t.references :job_education
      t.references :job_experience_level
      t.references :country
      t.references :city

      t.timestamps null: false
    end
    add_foreign_key :jobs, :users
    add_foreign_key :jobs, :companies
    add_foreign_key :jobs, :job_types
    add_foreign_key :jobs, :job_categories
    add_foreign_key :jobs, :countries
    add_foreign_key :jobs, :cities
    add_foreign_key :jobs, :job_statuses
    add_foreign_key :jobs, :functional_areas
    add_foreign_key :jobs, :job_educations
    add_foreign_key :jobs, :job_experience_levels
  end
end
