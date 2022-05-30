class AddJobHistory < ActiveRecord::Migration
  def change
    create_table :job_history do |t|
      t.string :job_action_type
      t.references :user, index: true, foreign_key: true
      t.references :job, index: true, foreign_key: true
      t.timestamps null: false
    end
  end
end
