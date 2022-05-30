class CreateEvaluationSubmitRequisitions < ActiveRecord::Migration
  def change
    create_table :evaluation_submit_requisitions do |t|
      t.references :evaluation_form, index: true, foreign_key: true
      t.references :evaluation_submit, index: true, foreign_key: true
      t.references :job_application, index: true, foreign_key: true
      t.references :organization, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true
      t.string :status
      t.boolean :active
      t.datetime :approved_at

      t.timestamps null: false
    end
  end
end
