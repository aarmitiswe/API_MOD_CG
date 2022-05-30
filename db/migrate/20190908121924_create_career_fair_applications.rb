class CreateCareerFairApplications < ActiveRecord::Migration
  def change
    create_table :career_fair_applications do |t|
      t.references :jobseeker, index: true, foreign_key: true
      t.references :career_fair, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
