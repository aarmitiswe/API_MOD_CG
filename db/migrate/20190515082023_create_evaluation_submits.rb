class CreateEvaluationSubmits < ActiveRecord::Migration
  def change
    create_table :evaluation_submits do |t|
      t.references :user, index: true, foreign_key: :user_id
      t.references :job_application, index: true, foreign_key: :job_application_id
      t.references :evaluation_form, index: true, foreign_key: :evaluation_form_id
      t.text :comment
      t.decimal :total_score

      t.timestamps null: false
    end
  end
end
