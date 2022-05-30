class CreateBoardingForms < ActiveRecord::Migration
  def change
    create_table :boarding_forms do |t|
      t.string :title
      t.string :owner_position
      t.references :job_application, index: true, foreign_key: true
      t.date :effective_joining_date
      t.integer :copy_number
      t.date :expected_joining_date
      t.attachment :signed_joining_document
      t.attachment :signed_stc_document

      t.timestamps null: false
    end
  end
end
