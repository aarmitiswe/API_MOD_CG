class CreateEvaluationAnswers < ActiveRecord::Migration
  def change
    create_table :evaluation_answers do |t|
      t.references :evaluation_submit, index: true, foreign_key: :evaluation_submit_id
      t.references :evaluation_question, index: true, foreign_key: :evaluation_question_id
      t.text :answer

      t.timestamps null: false
    end
  end
end
