class AddEndDateToOfferLetterRequest < ActiveRecord::Migration
  def change
    add_column :offer_letter_requests, :end_date, :date
  end
end
