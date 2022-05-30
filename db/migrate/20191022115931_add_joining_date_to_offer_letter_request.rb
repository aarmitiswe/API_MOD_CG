class AddJoiningDateToOfferLetterRequest < ActiveRecord::Migration
  def change
    add_column :offer_letter_requests, :joining_date, :date
  end
end
