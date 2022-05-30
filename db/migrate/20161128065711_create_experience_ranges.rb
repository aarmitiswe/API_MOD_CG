class CreateExperienceRanges < ActiveRecord::Migration
  def change
    create_table :experience_ranges do |t|
      t.integer :experience_from
      t.integer :experience_to

      t.timestamps null: false
    end
  end
end
