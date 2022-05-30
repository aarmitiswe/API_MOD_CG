class CreateJobseekerCertificates < ActiveRecord::Migration
  def change
    create_table :jobseeker_certificates do |t|
      t.string :name
      t.string :institute
      t.string :attachment
      t.string :grade
      t.references :jobseeker, index: true

      t.date :from
      t.date :to

      t.timestamps null: false
    end
    add_foreign_key :jobseeker_certificates, :jobseekers
  end
end
