class CreateEvaluationQuestions < ActiveRecord::Migration
  def change
    create_table :evaluation_questions do |t|
      t.string :name
      t.string :ar_name
      t.text :description
      t.text :ar_description
      t.references :evaluation_form, index: true, foreign_key: :evaluation_form_id
      t.string :question_type
      t.string :answers_list, default: [], array: true

      t.timestamps null: false
    end
  end
end
