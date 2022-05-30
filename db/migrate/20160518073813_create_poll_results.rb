class CreatePollResults < ActiveRecord::Migration
  def change
    create_table :poll_results do |t|
      t.references :user, index: true
      t.references :poll_answer, index: true

      t.timestamps null: false
    end
    add_foreign_key :poll_results, :users
    add_foreign_key :poll_results, :poll_answers
  end
end
