class CreateOfferLetters < ActiveRecord::Migration
  def change
    create_table :offer_letters do |t|
      t.attachment :document
      t.references :job_application_status_change, index: true, foreign_key: :job_application_status_change_id

      t.timestamps null: false
    end
  end
end
