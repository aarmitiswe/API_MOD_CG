class CreateRatings < ActiveRecord::Migration
  def change
    create_table :ratings do |t|
      t.references :creator, references: :users
      t.references :jobseeker, index: true, foreign_key: :jobseeker_id
      t.float :rate, default: 0.0

      t.timestamps null: false
    end

    add_foreign_key :ratings, :users, column: :creator_id
  end
end
