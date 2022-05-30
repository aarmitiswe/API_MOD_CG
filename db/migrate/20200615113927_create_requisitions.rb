class CreateRequisitions < ActiveRecord::Migration
  def change
    create_table :requisitions do |t|
      t.string :status
      t.references :user, index: true, foreign_key: :user_id
      t.references :job, index: true, foreign_key: :job_id

      t.timestamps null: false
    end
  end
end
