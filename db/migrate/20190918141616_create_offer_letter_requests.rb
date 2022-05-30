class CreateOfferLetterRequests < ActiveRecord::Migration
  def change
    create_table :offer_letter_requests do |t|
      t.float :basic_salary
      t.float :housing_salary
      t.float :transportation_salary
      t.float :mobile_allowance_salary
      t.float :total_salary
      t.references :job_application_status_change, index: true, foreign_key: :job_application_status_change_id
      t.references :offer_letter, index: true, foreign_key: :offer_letter_id
      t.string :offer_letter_type
      t.string :status_approval_one
      t.string :status_approval_two
      t.string :status_approval_three
      t.string :status_approval_four
      t.string :status_approval_five
      t.datetime :date_approval_one
      t.datetime :date_approval_two
      t.datetime :date_approval_three
      t.datetime :date_approval_four
      t.datetime :date_approval_five
      t.text :comment_approval_one
      t.text :comment_approval_two
      t.text :comment_approval_three
      t.text :comment_approval_four
      t.text :comment_approval_five
      t.text :reply_jobseeker
      t.string :status_jobseeker

      t.timestamps null: false
    end
  end
end
