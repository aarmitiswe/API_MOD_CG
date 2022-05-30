class CreatePollAnswers < ActiveRecord::Migration
  def change
    create_table :poll_answers do |t|
      t.string :answer
      t.references :poll_question, index: true

      t.timestamps null: false
    end
    add_foreign_key :poll_answers, :poll_questions
  end
end
