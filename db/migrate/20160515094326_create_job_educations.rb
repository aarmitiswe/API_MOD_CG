class CreateJobEducations < ActiveRecord::Migration
  def change
    create_table :job_educations do |t|
      t.string :level, null: false, default: ""
      t.integer :displayorder
      t.boolean :deleted, null: false, default: false

      t.timestamps null: false
    end
  end
end
