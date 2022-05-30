class CreateJobseekerCompanyBroadcasts < ActiveRecord::Migration
  def change
    create_table :jobseeker_company_broadcasts do |t|
      t.references :jobseeker, index: true, foreign_key: :jobseeker_id
      t.references :company, index: true, foreign_key: :company_id
      t.string :status

      t.timestamps null: false
    end
  end
end
