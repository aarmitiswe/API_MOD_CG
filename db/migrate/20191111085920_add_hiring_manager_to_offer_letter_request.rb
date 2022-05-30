class AddHiringManagerToOfferLetterRequest < ActiveRecord::Migration
  def change
    add_reference :offer_letter_requests, :hiring_manager, index: true, foreign_key: true
  end
end
