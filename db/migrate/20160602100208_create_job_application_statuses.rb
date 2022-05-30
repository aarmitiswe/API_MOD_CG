class CreateJobApplicationStatuses < ActiveRecord::Migration
  def change
    create_table :job_application_statuses do |t|
      t.string :status
      t.integer :order

      t.timestamps null: false
    end
  end
end
