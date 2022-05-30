class CreateJobRequests < ActiveRecord::Migration
  def change
    create_table :job_requests do |t|
      t.references :job, index: true, foreign_key: true
      t.references :hiring_manager, index: true, foreign_key: true
      t.integer :total_number_vacancies
      t.string :status_approval_one
      t.string :status_approval_two
      t.string :status_approval_three
      t.string :status_approval_four
      t.string :status_approval_five

      t.timestamps null: false
    end
  end
end
