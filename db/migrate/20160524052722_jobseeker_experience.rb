class JobseekerExperience < ActiveRecord::Migration
  def change
    create_table :jobseeker_experiences do |t|
      t.references :jobseeker, index: true
      t.references :sector, index: true
      t.references :country
      t.references :city
      t.string :position
      t.string :company
      t.string :department

      t.text :description
      t.date :from
      t.date :to

      t.timestamps null: false
    end
    add_foreign_key :jobseeker_experiences, :jobseekers
    add_foreign_key :jobseeker_experiences, :sectors
  end
end
