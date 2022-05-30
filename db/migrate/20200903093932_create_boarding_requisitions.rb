class CreateBoardingRequisitions < ActiveRecord::Migration
  def change
    create_table :boarding_requisitions do |t|
      t.references :job_application, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true
      t.string :status
      t.references :boarding_form, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
