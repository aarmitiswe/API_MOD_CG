class CreatePositions < ActiveRecord::Migration
  def change
    create_table :positions do |t|
      t.string :job_title
      t.string :ar_job_title
      t.string :job_description
      t.string :employment_type
      t.string :military_level
      t.string :military_force
      t.string :position_grade

      t.references :job_status, index: true
      t.references :grade, index: true
      t.references :job_experience_level, index: true
      t.references :job_type, index: true
      t.references :organization, index: true
      t.references :position_status, index: true
      t.references :position_cv_source, index: true

      t.timestamps null: false
    end
  end
end