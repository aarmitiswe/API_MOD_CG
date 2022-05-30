class AddApplicationLogs < ActiveRecord::Migration
  def change
    create_table :job_application_logs do |t|
      t.string :log_type
      t.references :user, index: true, foreign_key: true
      t.references :job_application, index: true, foreign_key: true
      t.timestamps null: false
    end
  end
end
