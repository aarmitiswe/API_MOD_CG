class CreateCalls < ActiveRecord::Migration
  def change
    create_table :calls do |t|
      t.references :user, index: true, foreign_key: true
      t.references :interview, index: true, foreign_key: true
      t.string :token
      t.integer :duration
      t.string :room

      t.timestamps null: false
    end
  end
end
