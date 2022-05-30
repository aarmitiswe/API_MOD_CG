class NewFieldsToOfferLetterRequest < ActiveRecord::Migration
  def change
    add_column :offer_letter_requests, :start_date, :date
    add_column :offer_letter_requests, :job_grade, :string
  end
end
