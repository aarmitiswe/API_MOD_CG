class CreateJobCertificates < ActiveRecord::Migration
  def change
    create_table :job_certificates do |t|
      t.references :job, index: true, foreign_key: :job_id
      t.references :certificate, index: true, foreign_key: :certificate_id
      t.string :required_grade

      t.timestamps null: false
    end
  end
end
