class CreateJobSkills < ActiveRecord::Migration
  def change
    create_table :job_skills do |t|
      t.references :job, index: true, foreign_key: :job_id
      t.references :skill, index: true, foreign_key: :skill_id
      t.integer :level

      t.timestamps null: false
    end
  end
end
