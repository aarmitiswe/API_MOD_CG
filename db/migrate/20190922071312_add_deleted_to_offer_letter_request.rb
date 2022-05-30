class AddDeletedToOfferLetterRequest < ActiveRecord::Migration
  def change
    add_column :offer_letter_requests, :deleted, :boolean, default: false
  end
end
