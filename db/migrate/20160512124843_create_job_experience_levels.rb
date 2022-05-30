class CreateJobExperienceLevels < ActiveRecord::Migration
  def change
    create_table :job_experience_levels do |t|
      t.string :level,  null: false, default: ""
      t.integer :display_order
      t.boolean :deleted, null: false, default: false

      t.timestamps null: false
    end
  end
end
