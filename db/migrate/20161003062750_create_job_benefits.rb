class CreateJobBenefits < ActiveRecord::Migration
  def change
    create_table :job_benefits do |t|
      t.references :job, index: true, foreign_key: :job_id
      t.references :benefit, index: true, foreign_key: :benefit_id

      t.timestamps null: false
    end
  end
end
