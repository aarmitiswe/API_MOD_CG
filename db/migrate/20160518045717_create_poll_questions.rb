class CreatePollQuestions < ActiveRecord::Migration
  def change
    create_table :poll_questions do |t|

      t.string :question
      t.string :poll_type
      t.boolean :multiple_selection
      t.boolean :active
      t.datetime :start_at
      t.datetime :expire_at
      t.references :user, index: true
      t.timestamps null: false
    end
    add_foreign_key :poll_questions, :users
  end
end
