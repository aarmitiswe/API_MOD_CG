class CreateInterviews < ActiveRecord::Migration
  def change
    create_table :interviews do |t|
      t.datetime :appointment
      t.string :time_zone
      t.string :comment
      t.string :channel
      t.string :contact
      t.references :job_application_status_change, index: true, foreign_key: :job_application_status_change_id

      t.timestamps null: false
    end
  end
end
